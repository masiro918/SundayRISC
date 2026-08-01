[![Run Tests](https://github.com/masiro918/SundayRISC/actions/workflows/run-tests.yml/badge.svg)](https://github.com/<OWNER>/<REPOSITORY>/actions/workflows/run-tests.yml)

***IMPORTANT! This software is, at least for now, very experimental. The software is fully a Sunday hobby project. It is possible, even likely, that the software is full of bugs. When using this software, please be aware that the software is very much a work in progress! Unfortunately, the documentation is also very incomplete.***
----

This program is a customized RISC-V assembly language implementation designed to demonstrate basic functionalities and interactions with a simplified virtual machine environment. It includes instructions and operations related to system calls, networking, and terminal output. Key features and architectural limitations are highlighted to provide insight into its operational mechanics.

## 1. Features

- **ECALL, MRET and Timer Interrupts**: 
  - Custom ECALL and MRET instructions are encoded as `addi` operations.
  - ECALL handler address is fixed to `0x10274` (`ADDRESS + 0x200`).
  - Timer interrupt handler address is separate and fixed to `0x1027C` (`ADDRESS + 0x208`).
  - Return address (`MEPC`) is memory mapped to address `0x1FFFFB` (little-endian, 4 bytes).
  - On ECALL, emulator stores `PC + 4` to `MEPC` and jumps to handler.
  - On MRET, emulator loads `PC` from `MEPC`.
  - `MEPC` can be modified by software (for example in handler) by writing to `0x1FFFFB`.
  - Timer interrupt is enabled by writing value `1` to `MMIO_BASE + 0x24` (`0x200024`).
  - While enabled, emulator raises timer interrupt after every 150 executed instructions.
  - On timer interrupt, emulator stores current `PC` to `MEPC` before jumping to handler.
  - During handler execution timer source is masked, and it is automatically re-enabled on `mret`.

- **Simplified Network Interface**:
  - Supports e.g. simple HTTP (GET request) network traffic.
  - The virtual network card facilitates connection without requiring configuration management (e.g., DHCP, DNS).
  - Ethernet frames are constructed and interpreted byte-by-byte, resembling NAT-like operations for creating and returning TCP connections.

-  **Very Simple Hard Disc**

  - Hard Drive device consists of 512-byte blocks. Each block has an address, with the maximum being `BLOCK_MAX`. When writing to the device, always write `512 * N` bytes.

- **Terminal Output**:
  - Allows single-byte characters to be printed directly to an on-screen terminal.

A complete overview of the hardware memory layout and device addresses can be found in the `memory_map.md` file.

## 2. Restrictions

- **System Call / Interrupt Flow**: 
  - ECALL trap vector is fixed (`0x10274`).
  - Timer interrupt handler vector is fixed separately (`0x1027C`).
  - Timer interrupt is periodic after one enable write (`MMIO_BASE + 0x24 = 1`).
  
- **Network Card Functionality**:
  - The network card operates under simplified conditions, handling only basic HTTP communications without external configurations.
  
- **Output Handling**:
  - Terminal operations are limited to a single character output at a time, restricting output bandwidth and complexity. 

This setup is designed for educational purposes to illustrate fundamental assembly programming concepts, system architecture, and the interaction between software and simulated hardware components.

## 3. Virtual Devices

You can read the system's memory map from the [`memory_map.md`](memory_map.md) file.

### 3.1. Network Card

| Address | Purpose |
|---------|---------|
| MMIO_BASE + 0x4 | (TX) Writes to the buffer to form an Ethernet frame one byte at a time. |
| MMIO_BASE + 0x8 | (RX) Reads the response byte-by-byte once the Ethernet frame is sent. |
| MMIO_BASE + 0xB | Status indicator; 0 if unread bytes exist, 1 if buffer is fully read. |

**Note**: You can conveniently create Ethernet frames suitable for the emulator using the `frame_creator.py` script.

### 3.2. Terminal 

| Address | Purpose |
|---------|---------|
| MMIO_BASE + 0x0 | Outputs the given byte as a character to the screen. |

### 3.3. Hard Disc

This device has some DMA-like (Direct Memory Access) capabilities. 

After writing to address MMIO_BASE + 0x14 the status indicator (MMIO_BASE + 0x10) changes 0 to 1. After the process is completed, the device changes the status indicator back to 0.

| Address | Purpose |
|---------|---------|
| MMIO_BASE + 0x10 | Status indicator; 0 = free, 1 = busy. Cannot be changed! |
| MMIO_BASE + 0x14 | Operation command: 0 = Write, 1 = Read |
| MMIO_BASE + 0x18 | Payload address |
| MMIO_BASE + 0x1B | How many blocks to read from RAM? (max. 256) |
| MMIO_BASE + 0x20 | Starting block in hd (block space: 0 -> 255) |

### 3.4. Timer Interrupt

| Address | Purpose |
|---------|---------|
| MMIO_BASE + 0x24 | Timer interrupt enable register. Write `1` to enable. |

Behavior summary:
- When enabled, emulator increments internal timer counter once per executed instruction.
- At counter value `150`, emulator takes timer interrupt and stores current `PC` to `MEPC` (`0x1FFFFB`).
- Emulator jumps to timer handler (`0x1027C`) and masks timer interrupts during handler execution.
- Handler returns with custom `mret` instruction, which restores `PC` from `MEPC` and re-enables timer interrupts.
- Because saved value is current `PC`, execution continues from interrupted instruction after `mret`.

## 4. Testing

Run the full test suite locally with:

```bash
./run_tests.sh
```

The `run_tests.sh` script starts a local HTTP server for test needs, runs `pytest` with a timeout, and cleans up the server automatically.

> **Build requirement for tests:** test programs are assembled with the provided `test_programs/assemble.sh` script, which produces flat binaries the emulator can run directly (without converting to ELF format).

### 4.1 Testing with Docker

A `Dockerfile` is included in the project root, so tests can be run in a containerized environment.

Build the image:

```bash
docker build -t riscv-emu-tests .
```

Run the tests in the container:

```bash
docker run --rm riscv-emu-tests
```

CI is configured using GitHub Actions in `.github/workflows/run-tests.yml` and runs on pushes and pull requests.

