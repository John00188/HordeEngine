#pragma once
#include <cstddef>
#include <cstdint>

namespace he
{
    struct Frame
    {
        std::uint64_t timestamp_ms = 0;
        std::uint32_t seq = 0;
    };

    struct PlayerInput
    {
        std::int32_t id = 0;
        float x = 0.f, y = 0.f, z = 0.f;
        float yaw = 0.f, pitch = 0.f;
    };

    // Stable stubs (no external deps yet)
    bool        connect(const char* endpoint = nullptr) noexcept;
    void        disconnect() noexcept;
    bool        is_connected() noexcept;
    const Frame* latest() noexcept;
    bool        send_players(const PlayerInput* arr, std::size_t count) noexcept;
}
