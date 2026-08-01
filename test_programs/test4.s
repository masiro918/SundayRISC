.equ MMIO_BASE, 0x200000
.equ STATUS_REG, 0x10
.equ OPERATION_REG, 0x14
.equ DATA_ADDR_REG, 0x18
.equ BLOCK_COUNT_REG, 0x1B
.equ DEVICE_ADDR_REG, 0x20

.section .text
.global _start

_start:

    # Load MMIO base address
    li t0, MMIO_BASE
       

wait_device_free1:
    lw t1, STATUS_REG(t0)

    # Continue while the device is free
    bnez t1, wait_device_free1
        
    # Set address of the data (write_buffer1)
    la t1, write_buffer1
    sw t1, DATA_ADDR_REG(t0)
    
    # Set the block count: block 1 (512 bytes)
    li t1, 1
    sw t1, BLOCK_COUNT_REG(t0)
    
    # Set device internal memory location: 12
    li t1, 12
    sw t1, DEVICE_ADDR_REG(t0)
    
    # Set operation type: 0 = write
    li t1, 0
    sw t1, OPERATION_REG(t0)
    
    # Wait for the operation to complete
wait_write1_complete:
    lw t1, STATUS_REG(t0)
    bnez t1, wait_write1_complete
        
    # Wait until the device is free
wait_device_free2:
    lw t1, STATUS_REG(t0)
    bnez t1, wait_device_free2
    
    # Set data address (write_buffer2)
    la t1, write_buffer2
    sw t1, DATA_ADDR_REG(t0)
    
    # Set block count: 1 block
    li t1, 1
    sw t1, BLOCK_COUNT_REG(t0)
    
    # Set device internal memory location: 24
    li t1, 24
    sw t1, DEVICE_ADDR_REG(t0)
    
    # Start operation
    li t1, 0
    sw t1, OPERATION_REG(t0)
    
    # Wait for the operation to complete
wait_write2_complete:
    lw t1, STATUS_REG(t0)
    bnez t1, wait_write2_complete
        
    # Wait until the device is free
wait_device_free3:
    lw t1, STATUS_REG(t0)
    bnez t1, wait_device_free3
    
    # Set address where data will be read (read_buffer1)
    la t1, read_buffer1
    sw t1, DATA_ADDR_REG(t0)
    
    # Set block count: 1 block
    li t1, 1
    sw t1, BLOCK_COUNT_REG(t0)
    
    # Set device internal memory location: 12
    li t1, 12
    sw t1, DEVICE_ADDR_REG(t0)
    
    # Start operation
    li t1, 1
    sw t1, OPERATION_REG(t0)
    
    # Wait for the operation to complete
wait_read1_complete:
    lw t1, STATUS_REG(t0)
    bnez t1, wait_read1_complete
    
    # Print read data (read_buffer1)
    la t2, read_buffer1      # t2 = pointer to data
print_loop1:
    lb t3, 0(t2)            # Load one byte
    beqz t3, print_done1    # If \0, stop
    sw t3, 0(t0)            # Write byte to sysout (MMIO_BASE)
    addi t2, t2, 1          # Move to the next byte
    j print_loop1
print_done1:
        
    # Wait until the device is free
wait_device_free4:
    lw t1, STATUS_REG(t0)
    bnez t1, wait_device_free4
    
    # Set address where data will be read (read_buffer2)
    la t1, read_buffer2
    sw t1, DATA_ADDR_REG(t0)
    
    # Set block count: 1 block
    li t1, 1
    sw t1, BLOCK_COUNT_REG(t0)
    
    # Set device internal memory location: 24
    li t1, 24
    sw t1, DEVICE_ADDR_REG(t0)
    
    # Start operation
    li t1, 1
    sw t1, OPERATION_REG(t0)
    
    # Wait for the operation to complete
wait_read4_complete:
    lw t1, STATUS_REG(t0)
    bnez t1, wait_read4_complete
    
    # Print read data (read_buffer2)
    la t2, read_buffer2      # t2 = pointer to data
print_loop2:
    lb t3, 0(t2)            # Load one byte
    beqz t3, print_done2    # If \0, stop
    sw t3, 0(t0)            # Write byte to sysout (MMIO_BASE)
    addi t2, t2, 1          # Move to the next byte
    j print_loop2
print_done2:
    
    # Program complete - final state
end:
    ebreak

# Data written to the device (512 bytes per block)
write_buffer1: .ascii "hello world\n\0"
.space 501  # Fill to 512 bytes

write_buffer2: .ascii "bye bye\n\0"
.space 505  # Fill to 512 bytes

# Buffers for data being read
read_buffer1: .space 512
read_buffer2: .space 512