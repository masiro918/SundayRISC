.global _start

_start:
    la a0, values         # Load address of values into a0
    li a1, 0x200004       # Load memory address 200004 into a1 (write eth0) 
    li t0, 0              # Initialize index

write_loop:
    lb t1, 0(a0)          # Load byte from values into t1
    sb t1, 0(a1)          # Store byte in memory address 200004
    addi a0, a0, 1        # Increment address in a0

    li t2, 122            # Length of the byte array
    addi t0, t0, 1        # Increment index
    blt t0, t2, write_loop # Loop if more bytes are left
read_and_move:
    li a0, 0x200008       # Initialize read address to 0x200008 (eth0 read)
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
    .byte 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 8, 0, 69, 0, 0, 85, 0, 1, 0, 0, 64, 6, 124, 160, 127, 0, 0, 1, 127, 0, 0, 1, 0, 20, 31, 64, 0, 0, 0, 0, 0, 0, 0, 0, 80, 2, 32, 0, 227, 38, 0, 0, 71, 69, 84, 32, 47, 82, 69, 65, 68, 77, 69, 46, 109, 100, 32, 72, 84, 84, 80, 47, 49, 46, 48, 10, 72, 111, 115, 116, 58, 32, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 56, 48, 48, 48, 10, 13, 10, 13, 10
