#pragma warning(disable: 4996)  // fopen / strncpy

#include "IbtSimulator.h"

#include <intrin.h>
#pragma intrinsic(_WriteBarrier)

#include <cassert>
#include <chrono>
#include <cstring>
#include <thread>

// ---------------------------------------------------------------------------
IbtSimulator::IbtSimulator() = default;

IbtSimulator::~IbtSimulator()
{
    close();
}

// ---------------------------------------------------------------------------
bool IbtSimulator::open(const std::string& path)
{
    close();

    m_filePath = path;

    if (!m_reader.openFile(path.c_str()))
        return false;

    if (!setupSharedMemory())
    {
        m_reader.closeFile();
        return false;
    }

    m_running.store(true);
    m_thread = std::thread(&IbtSimulator::simulatorThread, this);
    return true;
}

void IbtSimulator::close()
{
    m_running.store(false);
    if (m_thread.joinable())
        m_thread.join();

    teardownSharedMemory();
    m_reader.closeFile();
}

// ---------------------------------------------------------------------------
bool IbtSimulator::setupSharedMemory()
{
    const irsdk_header& ibtHdr = m_reader.fileHeader();

    if (ibtHdr.numVars <= 0 || ibtHdr.bufLen <= 0 || ibtHdr.sessionInfoLen <= 0)
        return false;

    // ------------------------------------------------------------------
    // Compute the shared memory layout.
    // Layout: [irsdk_header][session_string][var_headers][buf0][buf1][buf2]
    // ------------------------------------------------------------------
    int offset = 0;

    // 1. Main header
    offset += static_cast<int>(sizeof(irsdk_header));

    // 2. Session info string
    const int sessionInfoOffset = offset;
    offset += ibtHdr.sessionInfoLen;

    // 3. Variable headers
    const int varHeaderOffset = offset;
    offset += ibtHdr.numVars * static_cast<int>(sizeof(irsdk_varHeader));

    // 4. Triple-buffered frame data
    int bufOffsets[k_numBufs] = {};
    for (int i = 0; i < k_numBufs; ++i)
    {
        bufOffsets[i] = offset;
        offset += ibtHdr.bufLen;
    }

    m_sharedMemSize = offset;

    // ------------------------------------------------------------------
    // Create named shared memory (exactly what irsdkClient's irsdk_startup
    // opens with OpenFileMapping / IRSDK_MEMMAPFILENAME).
    // ------------------------------------------------------------------
    m_hMemMapFile = CreateFileMapping(
        INVALID_HANDLE_VALUE, nullptr,
        PAGE_READWRITE, 0, m_sharedMemSize,
        IRSDK_MEMMAPFILENAME);

    if (!m_hMemMapFile)
        return false;

    m_pSharedMem = static_cast<char*>(
        MapViewOfFile(m_hMemMapFile, FILE_MAP_ALL_ACCESS, 0, 0, m_sharedMemSize));

    if (!m_pSharedMem)
    {
        CloseHandle(m_hMemMapFile);
        m_hMemMapFile = nullptr;
        return false;
    }

    memset(m_pSharedMem, 0, m_sharedMemSize);

    // ------------------------------------------------------------------
    // Build the irsdk_header in the shared memory block.
    // ------------------------------------------------------------------
    irsdk_header liveHdr{};
    liveHdr.ver               = IRSDK_VER;
    liveHdr.status            = 0;                    // set to stConnected below
    liveHdr.tickRate          = ibtHdr.tickRate;
    liveHdr.sessionInfoUpdate = 0;
    liveHdr.sessionInfoLen    = ibtHdr.sessionInfoLen;
    liveHdr.sessionInfoOffset = sessionInfoOffset;
    liveHdr.numVars           = ibtHdr.numVars;
    liveHdr.varHeaderOffset   = varHeaderOffset;
    liveHdr.numBuf            = k_numBufs;
    liveHdr.bufLen            = ibtHdr.bufLen;

    for (int i = 0; i < k_numBufs; ++i)
    {
        liveHdr.varBuf[i].bufOffset = bufOffsets[i];
        liveHdr.varBuf[i].tickCount = -1;
    }

    m_pHeader = reinterpret_cast<irsdk_header*>(m_pSharedMem);
    memcpy(m_pHeader, &liveHdr, sizeof(irsdk_header));

    // ------------------------------------------------------------------
    // Copy session info string.
    // ------------------------------------------------------------------
    const char* sessionStr = m_reader.getSessionStr();
    if (sessionStr)
    {
        char* dest = m_pSharedMem + sessionInfoOffset;
        memcpy(dest, sessionStr, ibtHdr.sessionInfoLen);
        dest[ibtHdr.sessionInfoLen - 1] = '\0';
    }

    // ------------------------------------------------------------------
    // Copy variable headers.
    // ------------------------------------------------------------------
    const irsdk_varHeader* varHeaders = m_reader.varHeaders();
    if (varHeaders)
    {
        memcpy(m_pSharedMem + varHeaderOffset,
               varHeaders,
               ibtHdr.numVars * sizeof(irsdk_varHeader));
    }

    _WriteBarrier();

    // ------------------------------------------------------------------
    // Create named data-valid event (exactly what irsdkClient opens with
    // OpenEvent / IRSDK_DATAVALIDEVENTNAME).
    // Manual-reset event so all waiting clients are woken on each pulse.
    // ------------------------------------------------------------------
    m_hDataValidEvent = CreateEvent(nullptr, TRUE, FALSE, IRSDK_DATAVALIDEVENTNAME);
    if (!m_hDataValidEvent)
    {
        teardownSharedMemory();
        return false;
    }

    // Mark as connected — clients now recognise us as a live session.
    m_pHeader->status = irsdk_stConnected;
    _WriteBarrier();

    PulseEvent(m_hDataValidEvent);
    return true;
}

void IbtSimulator::teardownSharedMemory()
{
    // Signal clients we are going away.
    if (m_pHeader)
    {
        m_pHeader->status = 0;
        _WriteBarrier();
    }

    if (m_hDataValidEvent)
    {
        ResetEvent(m_hDataValidEvent);
        CloseHandle(m_hDataValidEvent);
        m_hDataValidEvent = nullptr;
    }

    if (m_pSharedMem)
    {
        UnmapViewOfFile(m_pSharedMem);
        m_pSharedMem = nullptr;
    }

    if (m_hMemMapFile)
    {
        CloseHandle(m_hMemMapFile);
        m_hMemMapFile = nullptr;
    }

    m_pHeader = nullptr;
}

// ---------------------------------------------------------------------------
void IbtSimulator::simulatorThread()
{
    using namespace std::chrono;

    const int tickRate = (m_reader.fileHeader().tickRate > 0)
                         ? m_reader.fileHeader().tickRate : 60;

    const auto frameDuration =
        duration_cast<nanoseconds>(duration<double>(1.0 / tickRate));

    int curBuf    = 0;
    int tickCount = 0;
    auto nextFrame = steady_clock::now();

    while (m_running.load())
    {
        // ---- advance one frame from the file ----
        if (!m_reader.getNextData())
        {
            if (m_loop)
            {
                // Rewind: re-open the same file (openFile seeks to frame 0).
                m_reader.closeFile();
                if (!m_reader.openFile(m_filePath.c_str()) || !m_reader.getNextData())
                    break;
            }
            else
            {
                break;
            }
        }

        // ---- copy raw frame buffer into the current shared-memory slot ----
        char* dst = m_pSharedMem + m_pHeader->varBuf[curBuf].bufOffset;
        memcpy(dst, m_reader.varBuf(), m_pHeader->bufLen);

        // Commit the write, then stamp the tick count to signal clients.
        _WriteBarrier();
        m_pHeader->varBuf[curBuf].tickCount = tickCount;
        _WriteBarrier();

        PulseEvent(m_hDataValidEvent);

        // ---- advance triple-buffer index and tick counter ----
        curBuf = (curBuf + 1) % k_numBufs;
        ++tickCount;

        // ---- pace to match the file's original tick rate ----
        nextFrame += frameDuration;
        std::this_thread::sleep_until(nextFrame);
    }

    m_running.store(false);
}