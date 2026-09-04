.global _start

_start:
    lui s0, 0x200              # MMIO stdout @ 0x200000

    # op=2 (write) : sys.txt <- "HELLO"
    li a0, 2
    la a1, filename_txt
    la a2, data_hello
    ecall
    li t0, 1
    bne a0, t0, fail

    # op=1 (read) : read sys.txt -> read_buf
    li a0, 1
    la a1, filename_txt
    la a2, read_buf
    ecall
    bne a0, t0, fail

    # print first 5 chars from read_buf (expected HELLO)
    la t1, read_buf
    li t2, 5
print_loop:
    lb t3, 0(t1)
    sb t3, 0(s0)
    addi t1, t1, 1
    addi t2, t2, -1
    bnez t2, print_loop

    # op=2 (write) : exec.bin <- [addi x0,x0,0 ; ebreak]
    li a0, 2
    la a1, filename_exec
    la a2, exec_payload
    ecall
    bne a0, t0, fail

    # op=3 (read and execute): load exec.bin to 0x18000 and jump there
    li a0, 3
    la a1, filename_exec
    li a2, 0x18000
    ecall

    # If op=3 returns here, treat as failure.
    li t4, 'F'
    sb t4, 0(s0)
    ebreak

fail:
    li t4, 'X'
    sb t4, 0(s0)
    ebreak

filename_txt:
    .asciz "sys.txt"

filename_exec:
    .asciz "exec.bin"

data_hello:
    .ascii "HELLO\r\n\r\n"

# payload bytes + write-terminator \r\n\r\n
# payload:
#   addi x0, x0, 0  -> 13 00 00 00   (prints 'b' when --debug-prints)
#   ebreak          -> 73 00 10 00
exec_payload:
    .byte 0x13, 0x00, 0x00, 0x00
    .byte 0x73, 0x00, 0x10, 0x00
    .byte 0x0D, 0x0A, 0x0D, 0x0A

read_buf:
    .space 32
