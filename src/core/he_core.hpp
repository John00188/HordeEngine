#pragma once
#include <string>
#include <atomic>
#include <chrono>

namespace he
{
    struct Status {
        std::string version;
        double      uptime_ms;
        uint64_t    jobs_enqueued;
        uint64_t    jobs_executed;
    };

    void     Init();
    void     Shutdown();
    Status   GetStatus();
    double   Bench(size_t iters);
}
