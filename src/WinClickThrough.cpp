#ifdef _WIN32
#include "WinClickThrough.h"
#include <windows.h>

namespace Win {
    void setClickThrough(QWindow* w, bool enabled) {
        if (!w) return;
        HWND hwnd = (HWND)w->winId();
        LONG_PTR ex = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
        if (enabled) {
            ex |= WS_EX_LAYERED | WS_EX_TRANSPARENT;
            SetWindowLongPtr(hwnd, GWL_EXSTYLE, ex);
            SetLayeredWindowAttributes(hwnd, 0, 255, LWA_ALPHA);
        }
        else {
            ex &= ~(WS_EX_TRANSPARENT | WS_EX_LAYERED);
            SetWindowLongPtr(hwnd, GWL_EXSTYLE, ex);
        }
    }
}
#endif
