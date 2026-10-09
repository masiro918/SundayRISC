    .section .text
    .globl _start

_start:
    li   t0, 0x200034      # t0 = seurattava muistiosoite

wait_loop:
    lw   t1, 0(t0)         # lue muistipaikan arvo
    li   t2, 1
    bne  t1, t2, wait_loop # jos arvo != 1, jatka odotusta

done:
    addi x0, x0, 0
    ebreak
