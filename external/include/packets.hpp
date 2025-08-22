
#pragma once
#include <cstdint>

static constexpr uint32_t HORDE_MAGIC = 0x484F5244; // 'HORD'
static constexpr int MAX_NPCS = 2048;
static constexpr int MAX_PLAYERS = 32;

enum class AnimState : uint8_t { Idle, Walk, Run, Attack, Hit, Die };

struct NPCUpdate {
  uint32_t id;        // engine-side id, maps to GMod ent
  float    px, py, pz;
  float    qx, qy, qz, qw; // orientation
  AnimState anim;
  uint16_t flags;     // bitset: attacking, ragdoll, etc.
};

struct PlayerState {
  float px, py, pz;
  float ax, ay, az;   // aim dir
};

struct FrameHeader {
  uint32_t magic;
  uint32_t frame_id;
  uint64_t time_us;
  uint32_t num_npcs;
  uint32_t num_players;
};

struct Frame {
  FrameHeader hdr;
  PlayerState players[MAX_PLAYERS];
  NPCUpdate   npcs[MAX_NPCS];
};

struct InputBuffer {
  uint32_t num_players;
  PlayerState players[MAX_PLAYERS];
};
