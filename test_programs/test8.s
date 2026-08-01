.global _start

.equ MMIO_BASE, 0x200000
.equ TIMER_ENABLE_REG, 0x24

_start:
    li t0, MMIO_BASE
    li t1, 1
    sw t1, TIMER_ENABLE_REG(t0)   # enable timer interrupts

    # print b 160 times
addi t3, t3, 80
begin:    
    addi t2, t2, 1
    addi x0, x0, 0  # prints
    bne t2, t3, begin

    ebreak

.org 0x208
handler:
    # print a once
    addi x0, x0, 2    # a (timer handler marker)
    addi x0, x0, 9    # cheat mret
    nop
