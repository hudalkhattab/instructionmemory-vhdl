# Instruction Memory (VHDL)

This repository contains a simple **Instruction Memory** module written in VHDL,
designed to be used in the **fetch stage of a CPU**.

## Features
- 32-bit instruction width
- 10-bit address width (1024 words = 4 KB)
- ROM-based memory
- Synchronous read
- Includes testbench for simulation

## Files
- `instructionmemory.vhd` – Instruction Memory module
- `instructionmemory_tb.vhd` – Testbench
- `waveform_instruction_memory.png` – Simulation waveform

## Instruction Memory Role in CPU
Instruction Memory is used during the **fetch stage** of the CPU pipeline.
At this stage:
1. The Program Counter (PC) provides the instruction address
2. The instruction is read from memory
3. The fetched instruction is sent to the decode stage



### Observations
- `addr` changes sequentially
- `instr_out` outputs the corresponding instruction
- ROM contents are correctly accessed
