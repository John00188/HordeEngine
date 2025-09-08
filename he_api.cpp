#include "he_api.hpp"
#include <chrono>

namespace he
{
    static bool g_connected = false;
    static Frame g_last{0, 0};

    bool connect(const char* /*endpoint*/) noexcept
    {
        g_connected = true;
        g_last.timestamp_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                                  std::chrono::steady_clock::now().time_since_epoch())
                                  .count();
        g_last.seq = 0;
        return true;
    }

    void disconnect() noexcept
    {
        g_connected = false;
    }

    bool is_connected() noexcept
    {
        return g_connected;
    }

    const Frame* latest() noexcept
    {
        return &g_last;
    }

    bool send_players(const PlayerInput* /*arr*/, std::size_t /*count*/) noexcept
    {
        if (!g_connected)
            return false;

        g_last.timestamp_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                                  std::chrono::steady_clock::now().time_since_epoch())
                                  .count();
        ++g_last.seq;
        return true;
    }
}

