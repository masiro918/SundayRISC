.global _start

_start:
    addi x0 , x0,   0   # prints b
    addi x0 , x0,   8   # cheat ecall
    addi x0 , x0,   0   # prints b
    addi x0 , x0,   0   # prints b
    addi x0 , x0,   0   # prints b
    ebreak

.org 0x200  # ecall handler addr
    addi x0 , x0,   2   # prints a
    addi x0 , x0,   9   # cheat mret
    addi x0 , x0,   2   # NOT prints a
    nop
