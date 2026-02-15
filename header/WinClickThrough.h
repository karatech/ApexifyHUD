#pragma once
#ifdef _WIN32
#include <QWindow>
namespace Win {
    void setClickThrough(QWindow* w, bool enabled);
}
#endif
