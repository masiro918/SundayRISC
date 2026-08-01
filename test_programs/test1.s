.global _start

_start:
    lui a0, 0x200
    li t0, 'h'           # Load 'h' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'e'           # Load 'e' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'l'           # Load 'l' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'l'           # Load 'l' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'o'           # Load 'o' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, ' '           # Load ' ' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'w'           # Load 'w' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'o'           # Load 'o' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'r'           # Load 'r' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'l'           # Load 'l' into t0
    sb t0, 0(a0)         # Store byte at address 200000
    li t0, 'd'           # Load 'd' into t0
    sb t0, 0(a0)        # Store byte at address 200000
    li t0, 0             # Load null terminator
    sb t0, 0(a0)        # Store byte at address 200000
    ebreak
