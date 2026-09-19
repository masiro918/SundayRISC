**Memory Map**
| ADDRESS | FUNCTION |
| -------------- | ---- |
| 0x000000 | Kernel Stack |
| 0x010074 | Start point of the kernel |
| 0x010274 | ECALL Trap Handler |
| 0x01027C | Timer Interrupt Handler |
| 0x1FFF00 | Interrupt context save area (ra, gp, sp, s0-s7, a0-a7; 19 x 4 bytes) |
| 0x1FFF4B | Last byte of interrupt context area |
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

**Interrupt context save layout (`0x1FFF00` - `0x1FFF4B`)**
- `0x1FFF00`: `ra`
- `0x1FFF04`: `gp`
- `0x1FFF08`: `sp`
- `0x1FFF0C`: `s0`
- `0x1FFF10`: `s1`
- `0x1FFF14`: `s2`
- `0x1FFF18`: `s3`
- `0x1FFF1C`: `s4`
- `0x1FFF20`: `s5`
- `0x1FFF24`: `s6`
- `0x1FFF28`: `s7`
- `0x1FFF2C`: `a0`
- `0x1FFF30`: `a1`
- `0x1FFF34`: `a2`
- `0x1FFF38`: `a3`
- `0x1FFF3C`: `a4`
- `0x1FFF40`: `a5`
- `0x1FFF44`: `a6`
- `0x1FFF48`: `a7`

**Interrupt behavior (implementation detail):**
- Custom `ecall` (`0x00800013`) and timer interrupt both save the register context above to `0x1FFF00`.
- For `ecall`, emulator stores `PC + 4` to `MEPC` (`0x1FFFFB`) and jumps to `0x10274`.
- For timer interrupt, emulator stores current `PC` to `MEPC` (`0x1FFFFB`) and jumps to `0x1027C`.
- Interrupt source is enabled by writing `1` to `0x200024`.
- Emulator triggers timer interrupt after every 150 executed instructions while enabled.
- Timer interrupts are masked during handler execution and automatically re-enabled on `mret`.
- On custom `mret` (`0x00900013`), emulator first restores saved register context from `0x1FFF00`, then sets `PC <- [MEPC]`.