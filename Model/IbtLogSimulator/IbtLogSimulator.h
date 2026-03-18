#pragma once

#include <windows.h>
#include <atomic>
#include <thread>
#include <string>

#include "irsdk_defines.h"
#include "irsdk_diskclient.h"


namespace ApexifyHUD::Model::IbtLogSimulator
{
    // Reads an .ibt telemetry file and replays it into the iRacing shared memory
    // (Local\IRSDKMemMapFileName / Local\IRSDKDataValidEvent), so that any SDK
    // client (irsdkClient, your HUD, etc.) can consume it as if iRacing were live.
    class IbtLogSimulator
    {
        // Thin subclass to expose the protected raw buffers we need.
        class IbtReader : public irsdkDiskClient
        {
        public:
            const irsdk_header& fileHeader() const { return m_header; }
            const irsdk_varHeader* varHeaders()  const { return m_varHeaders; }
            const char* varBuf()      const { return m_varBuf; }
        };

    public:
        IbtLogSimulator();
        ~IbtLogSimulator();

        // Open an .ibt file and begin simulating it into shared memory.
        // Returns false if the file cannot be read or shared memory cannot be created.
        bool open(const std::string& path);

        // Stop simulation and release all resources.
        void close();

        bool isRunning() const { return m_running.load(); }

        // When true, playback loops back to the start once the file ends.
        void setLoop(bool loop) { m_loop = loop; }
        bool getLoop()  const { return m_loop; }

    private:
        void simulatorThread();
        bool setupSharedMemory();
        void teardownSharedMemory();

        IbtReader           m_reader;
        std::string         m_filePath;

        std::thread         m_thread;
        std::atomic<bool>   m_running{ false };
        bool                m_loop{ true };

        HANDLE          m_hMemMapFile{ nullptr };
        HANDLE          m_hDataValidEvent{ nullptr };
        char* m_pSharedMem{ nullptr };
        irsdk_header* m_pHeader{ nullptr };

        int m_sharedMemSize{ 0 };

        static constexpr int k_numBufs = 3;
    };
}