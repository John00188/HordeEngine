
#pragma once
#include <cstdint>
#include <string>
#include <windows.h>
#include "packets.hpp"

struct DoubleBuffer {
  alignas(64) volatile uint32_t read_index;  // 0 or 1
  alignas(64) volatile uint32_t write_index; // 0 or 1
  Frame frames[2];
  InputBuffer input; // written by module, read by engine
};

class SHM {
public:
  SHM(const std::string& name, size_t bytes);
  ~SHM();

  // Engine side
  Frame& nextWriteFrame();
  void   publish();

  // Module side
  const Frame* latest() const;

  // Input (module writes, engine reads)
  void writeInput(const InputBuffer& in);
  InputBuffer readInput() const;

  // Common
  bool ok() const { return m_ok; }
  void* raw() const { return m_view; }

private:
  HANDLE m_file = nullptr;
  void*  m_view = nullptr;
  size_t m_size = 0;
  bool   m_ok = false;
};
