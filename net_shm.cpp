// net_shm.cpp  — drop-in
#include "packets.hpp"
#include <windows.h>
#include <string>
#include <cstring>   // std::memset
#include <cstdint>

#if defined(_MSC_VER)
#include <intrin.h> // _ReadWriteBarrier
#endif

// SHM layout (contiguous): [ Frame ][ InputBuffer ]

static HANDLE       g_shmHandle = nullptr;
static HANDLE       g_evtHandle = nullptr;
static Frame* g_shmFrame = nullptr;
static InputBuffer* g_shmInput = nullptr;

static std::string  g_shmName = "Global\\HordeEngineSharedMem";
static std::string  g_evtName = "Global\\HordeEngineEvent";

// Optional: call once before HE_Connect() if you want custom names.
void HE_SetNames(const char* shmName, const char* evtName) {
    if (shmName && *shmName) g_shmName = shmName;
    if (evtName && *evtName) g_evtName = evtName;
}

static void HE_CloseHandles() {
    if (g_shmFrame) {
        UnmapViewOfFile((void*)g_shmFrame);
        g_shmFrame = nullptr;
    }
    if (g_shmHandle) {
        CloseHandle(g_shmHandle);
        g_shmHandle = nullptr;
    }
    if (g_evtHandle) {
        CloseHandle(g_evtHandle);
        g_evtHandle = nullptr;
    }
    g_shmInput = nullptr;
}

// Idempotent connect; safe to call multiple times.
bool HE_Connect() {
    if (g_shmFrame && g_shmInput) return true;

    g_shmHandle = OpenFileMappingA(FILE_MAP_ALL_ACCESS, FALSE, g_shmName.c_str());
    if (!g_shmHandle) { HE_CloseHandles(); return false; }

    void* base = MapViewOfFile(g_shmHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    if (!base) { HE_CloseHandles(); return false; }

    g_shmFrame = reinterpret_cast<Frame*>(base);
    g_shmInput = reinterpret_cast<InputBuffer*>((char*)base + sizeof(Frame));

    // Event is optional; used to notify the other side.
    g_evtHandle = OpenEventA(EVENT_MODIFY_STATE, FALSE, g_evtName.c_str());

    return (g_shmFrame != nullptr) && (g_shmInput != nullptr);
}

bool HE_IsConnected() {
    return g_shmFrame != nullptr && g_shmInput != nullptr;
}

void HE_Disconnect() {
    HE_CloseHandles();
}

// Return raw pointer to latest frame (unchanged API).
const Frame* HE_Latest() {
    return g_shmFrame;
}

// Write InputBuffer to SHM and signal event (if present).
void HE_SendPlayers(const InputBuffer& in) {
    if (!g_shmInput) return;
    *g_shmInput = in;

#if defined(_MSC_VER)
    _ReadWriteBarrier();
#endif
    FlushProcessWriteBuffers();

    if (g_evtHandle) SetEvent(g_evtHandle);
}

// Debug: seed one NPC so Lua ReadFrame() has data.
bool HE_DebugSeed() {
    if (!g_shmFrame) return false;

    // Header (match names from packets.hpp)
    g_shmFrame->hdr.magic = HORDE_MAGIC;
    g_shmFrame->hdr.num_npcs = 1;

    // Type-agnostic access to first NPC slot.
    auto& n = g_shmFrame->npcs[0];
    std::memset(&n, 0, sizeof(n));

    // Field names should match your NPC struct in packets.hpp:
    n.id = 1;

    // anim is an enum (e.g., AnimState); assign via explicit cast
    n.anim = static_cast<decltype(n.anim)>(0);

    n.px = 0.0f; n.py = 0.0f; n.pz = 0.0f;
    n.qx = 0.0f; n.qy = 0.0f; n.qz = 0.0f; n.qw = 1.0f;

#if defined(_MSC_VER)
    _ReadWriteBarrier();
#endif
    FlushProcessWriteBuffers();

    if (g_evtHandle) SetEvent(g_evtHandle);
    return true;
}
