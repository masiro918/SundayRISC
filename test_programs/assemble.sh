riscv64-unknown-elf-gcc -nostdlib -march=rv32ima -mabi=ilp32 $1 -o test.elf
riscv64-unknown-elf-objcopy -O binary test.elf a.out