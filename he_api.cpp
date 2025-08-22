#include "he_api.hpp"

namespace he
{
    static bool  g_connected = false;
    static Frame g_last{ 0, 0 };

    bool connect(const char* /*endpoint*/) noexcept
    {
        g_connected = true;
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
        return g_connected;
    }
}
