.global _start

_start:
    la a0, values         # Load address of values into a0
    li a1, 0x200004       # Load memory address 200004 into a1 (eth0 read)
    li t0, 0              # Initialize index

write_loop:
    lb t1, 0(a0)          # Load byte from values into t1
    sb t1, 0(a1)          # Store byte at memory address 200004 (eth0 write)
    addi a0, a0, 1        # Increment address in a0

    li t2, 122            # Length of the byte array
    addi t0, t0, 1        # Increment index
    blt t0, t2, write_loop # Loop if more bytes are left
read_and_move:
    li a0, 0x200008       # Initialize read address to 0x200008
    li a1, 0x200000       # Initialize write address to 0x200000
    li a2, 0x20000B       # Initialize read address to 0x20000B

    li t3, 0              # Auxiliary variable for comparison

scan_loop:
    lb t1, 0(a0)          # Read byte from source
    sb t1, 0(a1)          # Write byte to destination

    lb t4, 0(a2)          # Read status register eth0
    beq t3, t4, end
    j scan_loop

end:
    ebreak                # End execution


values:
    .byte 255, 255, 255, 255, 255, 255, 0, 17, 34, 51, 68, 85, 8, 0, 69, 0, 0, 91, 0, 1, 0, 0, 64, 6, 57, 233, 192, 168, 1, 10, 127, 0, 0, 1, 212, 49, 31, 64, 0, 0, 0, 0, 0, 0, 0, 0, 80, 24, 32, 0, 238, 57, 0, 0, 71, 69, 84, 32, 47, 95, 95, 112, 121, 99, 97, 99, 104, 101, 95, 95, 32, 72, 84, 84, 80, 47, 49, 46, 49, 13, 10, 72, 111, 115, 116, 58, 32, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 56, 48, 48, 48, 13, 10, 13, 10
