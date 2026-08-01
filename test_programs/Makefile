FILES = test6.c 

ASM_FILES = start.s

all: compile

compile:
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 ${FILES} -S
	./trimmer.sh
	./assemble.sh test6.s

test7:
	riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 test7.c -S
	./trimmer.sh test7.s
	./assemble.sh test7.s
