// he_api.cpp — SAFE NO-OP STUB with real connected state (Option B)
#include "he_api.hpp"
#include <cstddef>

namespace he
{
    // Tracks whether we've "connected" (toggled by connect()/disconnect()).
    static bool s_connected = false;

    // Stable frame storage; pointer returned by latest().
    static Frame s_frame = {};

    bool connect(const char* /*endpoint*/) noexcept
    {
        // Do not touch external resources in the stub.
        s_connected = true;

        // Keep predictable values for anyone reading latest().
        s_frame.timestamp_ms = 0;
        s_frame.seq = 0;
        return true;
    }

    bool is_connected() noexcept
    {
        return s_connected;
    }

    const Frame* latest() noexcept
    {
        // Always return a valid pointer with stable storage.
        return &s_frame;
    }

    bool send_players(const PlayerInput* /*players*/, std::size_t /*count*/) noexcept
    {
        // No-op in stub; report success iff we're "connected".
        return s_connected;
    }

    void disconnect() noexcept
    {
        s_connected = false;
    }
}

