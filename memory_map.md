**Memory Map**
| ADDRESS | FUNCTION |
| -------------- | ---- |
| 0x00000 | Kernel Stack |
| 0x10074 | Start point of the kernel |
| 0x10274 | ECALL Trap Handler |
| 0x1027C | Timer Interrupt Handler |
| 0x1FFFFB | MEPC |
| 0x1FFFFF | The Last RAM Address (1 byte) |
| 0x200000 | Screen Output Character      |
| 0x200004 | Ethernet Frame Buffer Write (TX) |
| 0x200008 | Ethernet Frame Response Read (RX) |
| 0x20000B | Status Indicator Ethernet |
| 0x200010 | Status Indicator Hard Disc |
| 0x200014 | Operation Command Hard Disc |
| 0x200018 | Payload Address Hard Disc |
| 0x20001B | RAM Read Blocks (max: 256) Hard Disc  |
| 0x200020 | Starting Block in HD (0 to 255) |
| 0x200024 | Timer Interrupt Enable (write `1`) |

**Timer interrupt behavior (implementation detail):**
- Interrupt source is enabled by writing `1` to `0x200024`.
- Emulator triggers timer interrupt after every 150 executed instructions while enabled.
- On interrupt, emulator stores current `PC` to `MEPC` (`0x1FFFFB`) and jumps to `0x1027C`.
- Timer interrupts are masked during handler execution and automatically re-enabled on `mret`.
- Return from handler uses custom `mret` behavior: `PC <- [MEPC]`.