#!/usr/bin/env python3
"""
MIPS-32 CPU, Cache, and Memory Bus Architectural Simulator.
Simulates a classic RISC execution pipeline with basic cache controller logic.
"""

import sys

class MemoryBus:
    """Simulates physical system RAM (Byte-Addressable)."""
    def __init__(self, size=1024):
        self.size = size
        self.memory = [0] * size

    def load_initial_values(self, data_dict):
        """Initializes memory cells from a parsed configuration state."""
        for address, value in data_dict.items():
            if 0 <= address < self.size:
                self.memory[address] = value

    def read_word(self, address):
        """Reads a 32-bit word (4 bytes) from memory."""
        if address % 4 != 0:
            print(f"[MEMORY ERROR] Unaligned Word Read at Address: {address}")
            return 0
        if 0 <= address <= self.size - 4:
            # Reconstruct 32-bit integer from 4 byte slots
            return self.memory[address]
        print(f"[MEMORY ERROR] Out of Bounds Read at Address: {address}")
        return 0

    def write_word(self, address, value):
        """Writes a 32-bit word (4 bytes) into memory."""
        if address % 4 != 0:
            print(f"[MEMORY ERROR] Unaligned Word Write at Address: {address}")
            return
        if 0 <= address <= self.size - 4:
            self.memory[address] = value & 0xFFFFFFFF
        else:
            print(f"[MEMORY ERROR] Out of Bounds Write at Address: {address}")


class CacheController:
    """Simulates a basic Direct-Mapped Cache system."""
    def __init__(self, num_lines=8):
        self.num_lines = num_lines
        self.enabled = False
        # Cache structure: { line_index: { "tag": int, "valid": bool, "data": int } }
        self.lines = {i: {"tag": -1, "valid": False, "data": 0} for i in range(num_lines)}
        self.hits = 0
        self.misses = 0

    def flush(self):
        """Invalidates all cache metadata blocks."""
        for i in range(self.num_lines):
            self.lines[i]["valid"] = False
            self.lines[i]["tag"] = -1
            self.lines[i]["data"] = 0
        print("[CACHE] Cache Flushed (All lines invalidated).")

    def access(self, address, memory_bus, write_value=None):
        """
        Handles reads and writes through the cache wrapper.
        Implements a Write-Through methodology for write cycles.
        """
        if not self.enabled:
            if write_value is not None:
                memory_bus.write_word(address, write_value)
                return None
            return memory_bus.read_word(address)

        # Simplified direct mapping: Line index derived from word address
        word_addr = address // 4
        line_idx = word_addr % self.num_lines
        tag = word_addr // self.num_lines

        cache_line = self.lines[line_idx]

        # Write Operation (Write-Through)
        if write_value is not None:
            print(f"[CACHE WRITE] Address: {address} -> Updating Cache and Main Memory.")
            cache_line["tag"] = tag
            cache_line["valid"] = True
            cache_line["data"] = write_value
            memory_bus.write_word(address, write_value)
            return None

        # Read Operation
        if cache_line["valid"] and cache_line["tag"] == tag:
            self.hits += 1
            print(f"[CACHE HIT] Address: {address} found in Line {line_idx}.")
            return cache_line["data"]
        else:
            self.misses += 1
            print(f"[CACHE MISS] Address: {address} fetching from Memory Bus.")
            # Fetch from main memory, update cache line
            data_from_mem = memory_bus.read_word(address)
            cache_line["tag"] = tag
            cache_line["valid"] = True
            cache_line["data"] = data_from_mem
            return data_from_mem


class CPUMicroarchitecture:
    """Core Processor simulating registers, ISA micro-ops, and pipeline steps."""
    def __init__(self, memory_bus):
        self.registers = [0] * 32  # R0 - R31 MIPS General Purpose Registers
        self.pc = 0                # Program Counter
        self.memory_bus = memory_bus
        self.cache = CacheController()
        self.instructions = []
        self.halted = False

    def load_program(self, instructions):
        """Loads clean assembly instruction lists into the core execution array."""
        self.instructions = instructions

    def step(self):
        """Executes a single instruction cycle via fetch-decode-execute."""
        if self.halted or self.pc // 4 >= len(self.instructions):
            self.halted = True
            return

        current_pc = self.pc
        # Fetch
        raw_instruction = self.instructions[self.pc // 4].strip()
        self.pc += 4  # Increment PC immediately (MIPS Architecture Standard)

        if not raw_instruction or raw_instruction.startswith("#"):
            return

        print(f"\n--- [FETCH] PC: {current_pc} -> Executing: '{raw_instruction}' ---")
        
        # Parse / Decode
        parts = raw_instruction.replace(",", " ").split()
        opcode = parts[0].upper()
        args = parts[1:]

        # Execute / Memory / Writeback
        try:
            self._execute_opcode(opcode, args, current_pc)
        except Exception as err:
            print(f"[EXECUTION TRAP] Failed processing instruction line: {raw_instruction}. Error: {err}")
            self.halted = True

        # Enforce R0 hardwired to ground (0)
        self.registers[0] = 0
        self._print_register_snapshot()

    def _execute_opcode(self, opcode, args, current_pc):
        if opcode == "ADD":
            # ADD Rd, Rs, Rt
            rd, rs, rt = int(args[0][1:]), int(args[1][1:]), int(args[2][1:])
            self.registers[rd] = self.registers[rs] + self.registers[rt]
        
        elif opcode == "ADDI":
            # ADDI Rt, Rs, immd
            rt, rs, immd = int(args[0][1:]), int(args[1][1:]), int(args[2])
            self.registers[rt] = self.registers[rs] + immd

        elif opcode == "SUB":
            # SUB Rd, Rs, Rt
            rd, rs, rt = int(args[0][1:]), int(args[1][1:]), int(args[2][1:])
            self.registers[rd] = self.registers[rs] - self.registers[rt]

        elif opcode == "SLT":
            # SLT Rd, Rs, Rt
            rd, rs, rt = int(args[0][1:]), int(args[1][1:]), int(args[2][1:])
            self.registers[rd] = 1 if self.registers[rs] < self.registers[rt] else 0

        elif opcode == "BNE":
            # BNE Rs, Rt, offset
            rs, rt, offset = int(args[0][1:]), int(args[1][1:]), int(args[2])
            if self.registers[rs] != self.registers[rt]:
                self.pc = current_pc + 4 + (offset * 4)
                print(f"[BRANCH] BNE Taken. Diverting PC path to target: {self.pc}")

        elif opcode == "J":
            # J target
            target = int(args[0])
            self.pc = target * 4
            print(f"[JUMP] Jump unconditional executed. PC set to: {self.pc}")

        elif opcode == "JAL":
            # JAL target (Link register is R7 per project constraints spec)
            target = int(args[0])
            self.registers[7] = current_pc + 4
            self.pc = target * 4
            print(f"[JUMP & LINK] Subroutine targeted. R7 set to {self.registers[7]}. PC set to: {self.pc}")

        elif opcode == "LW":
            # LW Rt, offset(Rs) -> Syntax parsed: LW R1, 4(R2)
            rt = int(args[0][1:])
            offset_part, rs_part = args[1].split("(")
            offset = int(offset_part)
            rs = int(rs_part.replace(")", "")[1:])
            
            target_address = self.registers[rs] + offset
            self.registers[rt] = self.cache.access(target_address, self.memory_bus)

        elif opcode == "SW":
            # SW Rt, offset(Rs)
            rt = int(args[0][1:])
            offset_part, rs_part = args[1].split("(")
            offset = int(offset_part)
            rs = int(rs_part.replace(")", "")[1:])
            
            target_address = self.registers[rs] + offset
            self.cache.access(target_address, self.memory_bus, write_value=self.registers[rt])

        elif opcode == "CACHE":
            code = int(args[0])
            if code == 0:
                self.cache.enabled = False
                print("[CACHE CONFIG] Cache Subsystem Disabled.")
            elif code == 1:
                self.cache.enabled = True
                print("[CACHE CONFIG] Cache Subsystem Enabled.")
            elif code == 2:
                self.cache.flush()

        elif opcode == "HALT":
            print("\n*** [SYSTEM] HALT instruction reached. Shutting down pipeline core. ***")
            self.halted = True

    def _print_register_snapshot(self):
        active_regs = [f"R{i}: {self.registers[i]}" for i in range(32) if self.registers[i] != 0 or i in [1, 2, 3, 7]]
        print(f"[REGISTERS] {', '.join(active_regs)}")


# ============================================================================
-- DRIVER AND EMULATION TESTBENCH RUNTIME
# ============================================================================
if __name__ == "__main__":
    # Mocking initialization profiles to ensure standalone compilation capacity
    simulated_mem_init = {
        64: 125,   # Memory address 64 contains baseline value 125
        128: 500   # Memory address 128 contains baseline value 500
    }

    simulated_assembly_program = [
        "ADDI R1, R0, 64",      # R1 = 64 (Base pointer pointer)
        "CACHE 1",              # Enable internal cache monitoring controller
        "LW R2, 0(R1)",         # Load address 64 into R2 (Cache Miss -> Fetch)
        "LW R3, 0(R1)",         # Load address 64 into R3 (Cache Hit -> Fast read)
        "ADDI R4, R0, 25",      # R4 = 25
        "ADD R5, R2, R4",       # R5 = 125 + 25 = 150
        "SW R5, 64(R1)",        # Write R5 (150) to address 128 (64+64) (Cache Write-thru)
        "LW R6, 64(R1)",        # Read back address 128 (Cache Hit)
        "HALT"                  # Terminate core
    ]

    print("==================================================================")
    print("      INITIALIZING CODECADEMY COMPUTER ARCHITECTURE SIMULATOR     ")
    print("==================================================================")
    
    # Spin up hardware components
    bus = MemoryBus()
    bus.load_initial_values(simulated_mem_init)
    cpu = CPUMicroarchitecture(bus)
    cpu.load_program(simulated_assembly_program)

    # Core execution cycle loop
    while not cpu.halted:
        cpu.step()

    print("\n==================================================================")
    print("                    FINAL EXEUCTION METRICS                       ")
    print("==================================================================")
    print(f"Total Cache Hits:   {cpu.cache.hits}")
    print(f"Total Cache Misses: {cpu.cache.misses}")
    print(f"Final Value in Memory Cell 128: {bus.read_word(128)}")
    print("==================================================================")