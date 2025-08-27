#include "he_core.hpp"

using Clock = std::chrono::steady_clock;

namespace {
    Clock::time_point g_start;
    std::atomic<uint64_t> g_jobs_enqueued{0};
    std::atomic<uint64_t> g_jobs_executed{0};
}

namespace he
{
    void Init()
    {
        g_start = Clock::now();
        g_jobs_enqueued = 0;
        g_jobs_executed = 0;
    }

    void Shutdown()
    {
        // nothing yet
    }

    Status GetStatus()
    {
        Status s;
        s.version = "1.0.0-Improvementinator";
        s.uptime_ms = std::chrono::duration<double, std::milli>(Clock::now() - g_start).count();
        s.jobs_enqueued = g_jobs_enqueued.load();
        s.jobs_executed = g_jobs_executed.load();
        return s;
    }

    // simple CPU-bound benchmark to prove native call + timing
    double Bench(size_t iters)
    {
        auto t0 = Clock::now();
        volatile double acc = 0.0;
        for (size_t i = 0; i < iters; ++i) {
            acc += (i * 0.000001) * (i % 7 + 1);
        }
        auto t1 = Clock::now();
        (void)acc;
        return std::chrono::duration<double, std::milli>(t1 - t0).count();
    }
}
