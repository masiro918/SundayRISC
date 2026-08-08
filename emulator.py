"""
Copyright (C) 2026 Matias Siro

This program is free software; you can redistribute it and/or modify 
it under the terms of the GNU General Public License as published by 
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program; if not, write to the Free Software Foundation, Inc., 
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
"""

from unicorn import * # pyright: ignore[reportWildcardImportFromLibrary]
from unicorn.riscv_const import * # pyright: ignore[reportWildcardImportFromLibrary]
from capstone import * # pyright: ignore[reportWildcardImportFromLibrary]
from scapy.layers.l2 import Ether

from tcpip_proxy import TCPIPProxy
from misc import *
from hd_device import VirtHD


ADDRESS = 0x10074

#############################
DEBUG_MODE = False
DEBUG_PRINTS = False
#############################

#############################
# CONFIGURATION OF THE MMIO #
#############################
ADDRESS_ECALL = ADDRESS + 0x200
ADDRESS_TIMER_INT = ADDRESS + 0x208
MMIO_BASE = 0x200000  # Base address for MMIO
ADDRESS_MEPC = 0x1FFFFB
ADDRESS_CONTEXT = 0x1FFF00

CONTEXT_REGISTERS = [
    UC_RISCV_REG_RA,
    UC_RISCV_REG_GP,
    UC_RISCV_REG_SP,
    UC_RISCV_REG_S0,
    UC_RISCV_REG_S1,
    UC_RISCV_REG_S2,
    UC_RISCV_REG_S3,
    UC_RISCV_REG_S4,
    UC_RISCV_REG_S5,
    UC_RISCV_REG_S6,
    UC_RISCV_REG_S7,
    UC_RISCV_REG_A0,
    UC_RISCV_REG_A1,
    UC_RISCV_REG_A2,
    UC_RISCV_REG_A3,
    UC_RISCV_REG_A4,
    UC_RISCV_REG_A5,
    UC_RISCV_REG_A6,
    UC_RISCV_REG_A7,
]

###################################################################################

MEM_SIZE = 2 * 1024 * 1024
MMIO_SIZE = 0x1000    # 4KB

# the flag syscalls and interrupts
SYSCALL_FLAG = False
MRET_FLAG = False
TIMER_INTERRUPT_ENABLED = False
TIMER_FLAG = False
TIMER_SET = False
timeout = 100

# the eth0 interface
eth0_buffer = bytes()
ptr_eth0_buffer = 0

# the hard disc device
hd_DEVICE_ADDR_REG = 0
hd_BLOCK_COUNT_REG = 0
hd_DATA_ADDR_REG = 0

hd=VirtHD()

# initialize the program counter
pc=ADDRESS
# initilize the return value register for ecalls
mepc = 0x0

# initialize emulator in RISC-V 32-bit mode
mu = Uc(UC_ARCH_RISCV, UC_MODE_RISCV32)

# map 2MB memory for this emulation
mu.mem_map(0, MEM_SIZE)

file_output = str()

def DEBUG(msg: str, end=None):
    global DEBUG_MODE
    if DEBUG_MODE:
        if end != None:
            print(msg, end=end)
            return
        print(msg)
        return
    return

def read_binary_file_to_program_constant(file_path):
    try:
        with open(file_path, 'rb') as file:
            program = file.read()
            return program
    except IOError as e:
        raise Exception(f"Error reading file {file_path}: {e}")


def save_interrupt_context(uc):
    for i, reg in enumerate(CONTEXT_REGISTERS):
        reg_value = int(uc.reg_read(reg))
        uc.mem_write(ADDRESS_CONTEXT + (i * 4), reg_value.to_bytes(4, 'little'))


def restore_interrupt_context(uc):
    for i, reg in enumerate(CONTEXT_REGISTERS):
        reg_value = uc.mem_read(ADDRESS_CONTEXT + (i * 4), 4)
        uc.reg_write(reg, int.from_bytes(reg_value, 'little'))


def hook_code(uc, address, size, user_data):
    """
    Callback for tracing the instructions.
    """

    global SYSCALL_FLAG
    global MRET_FLAG

    if size == 4:
        # Disassemble and print the current instruction
        DEBUG(f">>> Tracing instruction at 0x{address:x} ", end='')
        md = Cs(CS_ARCH_RISCV, CS_MODE_RISCV32)
        for i in md.disasm(uc.mem_read(address, size), 0x0):
            if uc.mem_read(address, size) == b'\x13\x00\x80\x00':
                DEBUG("\tecall")
                return
            if uc.mem_read(address, size) == b'\x13\x00\x90\x00':
                DEBUG("\tmret")
                return
            DEBUG("\t%s\t%s" % (i.mnemonic, i.op_str))
    else:
        DEBUG(f">>> Tracing instruction at 0x{address:x}")
        raise Exception("Illegal instruction length! ", size)

    # THESE ARE CUSTOM INSTRUCTIONS FOR 'REAL' ecall and mret

    # in case of ebreak, stop emulation to set exit_emulation to True
    if uc.mem_read(address, size) == b'\x73\x00\x10\x00':
        DEBUG(">>> Emulation stopped at 0x%x" %address)
        raise Exception("END")

    # these are the instructions that are used to help debugging and testing
    global DEBUG_PRINTS
    if uc.mem_read(address, size) == b'\x13\x00\x20\x00':
        if DEBUG_PRINTS: print('a', end='', flush=True)
    if uc.mem_read(address, size) == b'\x13\x00\x00\x00':
        if DEBUG_PRINTS: print('b', end='', flush=True)

def mmio_read_cb(uc, offset, size, data):
    global eth0_buffer
    global ptr_eth0_buffer
    global hd

    # read response eth0
    if offset == 0x8:
        if eth0_buffer != None:
            try:
                if ptr_eth0_buffer == (len(eth0_buffer) - 1):
                    uc.emu_stop()
                val = eth0_buffer[ptr_eth0_buffer]
                ptr_eth0_buffer = ptr_eth0_buffer + 1
                return val
            except Exception as e:
                return 0x0
        return 0x0
    
    # check the status of eth0 response buffer
    if offset == 0xB:
        if eth0_buffer != None:
            if ptr_eth0_buffer < len(eth0_buffer):
                return 0x1
            eth0_buffer = bytes()
            return 0x0
    
    if offset == 0x10:
        return hd.read_status()
        
    return 0x100

def mmio_write_cb(uc, offset, size, value, data):
    global eth0_buffer
   
    #write to MMIO_BASE + 0x0 -> write to sysout
    if offset == 0x0:
        global file_output
        if value < 256:
            b = bytes([value])
            if b == b"\x0A":
                file_output += "\n"
                print()
                return
            if b == b"\x00": return
            if "\\x" in str(b)[2:-1]: return
            char = str(b)[2:-1]
            print(char, end='', flush=True)
            file_output += char
            return
    #write to MMIO_BASE + 0x4 -> write to eth0 interface
    if offset == 0x4:
        if value < 256:
            b = bytes([value])
            eth0_buffer = eth0_buffer + b

            if len(eth0_buffer) > 4:
                try:
                    if eth0_buffer[-4:].decode("utf-8") == "\r\n\r\n":
                        # Let's construct the eth frame and send it!
                        received_frame = Ether(eth0_buffer)
                        src_ip, dst_ip, _, dst_port = parse_ethernet_frame(bytes(received_frame))

                        proxy = TCPIPProxy(dst_ip, int(dst_port), src_ip)
                        proxy.open_connection()

                        frames = proxy.send_frame(bytes(received_frame))

                        eth0_buffer = None
                        eth0_buffer = b''.join(frames) # type: ignore

                        proxy.close_connection()
                except Exception as e:
                    return
            return       

    #write to MMIO_BASE + 0x10 -> the hard disc
    global hd_DATA_ADDR_REG         # 0x18
    global hd_BLOCK_COUNT_REG       # 0x1B
    global hd_DEVICE_ADDR_REG       # 0x20

    global hd
        
    # operation
    if offset == 0x14:
        if hd.read_status() != 0:
            return
        
        if value == 0:
            # write
            data = uc.mem_read(hd_DATA_ADDR_REG, hd_BLOCK_COUNT_REG * 512)
            hd.write(data, hd_DEVICE_ADDR_REG)
            return
        if value == 1:
            # read
            data = hd.read(hd_DEVICE_ADDR_REG, hd_BLOCK_COUNT_REG)
            hd.set_status(1)
            uc.mem_write(hd_DATA_ADDR_REG, data)
            hd.set_status(0)
            return
        return
        
    # data addr
    if offset == 0x18:
        if hd.read_status() != 0:
            return
        hd_DATA_ADDR_REG = value
        return
        
    # block count
    if offset == 0x1B:
        if hd.read_status() != 0:
            return
        hd_BLOCK_COUNT_REG = value
        return
        
    # device address
    if offset == 0x20:
        if hd.read_status() != 0:
            return
        hd_DEVICE_ADDR_REG = value
        return

    ####################
    # TIMER INTERRUPTS #
    ####################

    # set interruptson
    if offset == 0x24:
        global TIMER_INTERRUPT_ENABLED
        global TIMER_SET
        if TIMER_INTERRUPT_ENABLED != True:
            if value == 1:
                TIMER_SET = True
                TIMER_INTERRUPT_ENABLED = True
            return
    # set frequence
    if offset == 0x28:
        global timeout
        timeout = value
        return

    return

def next_inst_ecall(inst):
    if inst == b'\x13\x00\x80\x00':
        DEBUG("ECALL")
        return True
    return False

def next_inst_mret(inst):
    if inst == b'\x13\x00\x90\x00':
        DEBUG("MRET")
        return True
    return False

def hook_mem(uc, access, address, size, value, user_data):
    print(f"access={access} addr={hex(address)} size={size} value={hex(value)}")
    return False

import sys

def main(program="a.out"):
    global DEBUG_MODE
    global DEBUG_PRINTS
    global pc
    global file_output

    _breakpoint = 0
    breakpoint_set = False
    init_fs_path = None
    init_fs_addr = None

    try:
        for arg in sys.argv[2:]:
            if arg == "--debug":
                DEBUG_MODE = True
                continue
            if arg == "--debug-prints":
                DEBUG_PRINTS = True
                continue
            if arg == "--no-debug-prints":
                DEBUG_PRINTS = False
                continue
            if arg.startswith("--breakpoint="):
                addr = arg.split("=", 1)[1]
                _breakpoint = int(addr, 0)
                breakpoint_set = True
                print("breakpoint set", hex(_breakpoint))
                continue
            if arg.startswith("--init-fs=") or arg.startswith("--init_fs="):
                init_fs_path = arg.split("=", 1)[1]
                continue
            if arg.startswith("--init-fs-addr=") or arg.startswith("--init_fs_addr="):
                addr = arg.split("=", 1)[1]
                init_fs_addr = int(addr, 0)
                continue

            raise Exception(f"Unknown argument: {arg}")

        if (init_fs_path is None) != (init_fs_addr is None):
            raise Exception("Both --init-fs and --init-fs-addr must be set together")

        # Load program
        PROGRAM = read_binary_file_to_program_constant(program)

        mu.mem_write(ADDRESS, PROGRAM)

        if init_fs_path is not None and init_fs_addr is not None:
            init_fs = read_binary_file_to_program_constant(init_fs_path)
            init_fs_end = init_fs_addr + len(init_fs)
            if init_fs_addr < 0 or init_fs_end > MEM_SIZE:
                raise Exception(
                    f"init_fs does not fit in RAM: addr={hex(init_fs_addr)} size={len(init_fs)}"
                )
            mu.mem_write(init_fs_addr, init_fs)
            DEBUG(f"Loaded init_fs '{init_fs_path}' to {hex(init_fs_addr)} ({len(init_fs)} bytes)")

        # Add hooks
        mu.hook_add(UC_HOOK_CODE, hook_code)
        mu.hook_add(
            UC_HOOK_MEM_WRITE_UNMAPPED |
            UC_HOOK_MEM_READ_UNMAPPED,
            hook_mem
        )
        mu.mmio_map(MMIO_BASE, MMIO_SIZE, mmio_read_cb, None, mmio_write_cb, None)
        mu.reg_write(UC_RISCV_REG_PC, pc)

        # Emulate code
        DEBUG("Emulation starting...")

        DEBUG("PC" + str(pc))
        timer_i = 0
        while True:
            global TIMER_INTERRUPT_ENABLED
            global TIMER_FLAG
            if TIMER_INTERRUPT_ENABLED:
                timer_i += 1
            if pc >= (ADDRESS + len(PROGRAM)): # type: ignore
                break
            if DEBUG_MODE: input()

            if pc == _breakpoint: # and breakpoint_set == True:
                input()
                DEBUG_MODE = True
            
            if next_inst_ecall(mu.mem_read(pc, 4)): # pyright: ignore[reportArgumentType]
                if DEBUG_MODE: print(f">>> Tracing instruction at {hex(pc)} \tecall\n")
                save_interrupt_context(mu)
                mepc = int(mu.reg_read(UC_RISCV_REG_PC)) + 4 # pyright: ignore[reportArgumentType]
                mu.mem_write(ADDRESS_MEPC, mepc.to_bytes(4, 'little'))
                pc = ADDRESS_ECALL
                TIMER_INTERRUPT_ENABLED = False

            if timer_i == 150:
                timer_i = 0
                if TIMER_INTERRUPT_ENABLED:
                    if DEBUG_MODE: print("TIMER_INT")
                    TIMER_INTERRUPT_ENABLED = False
                    TIMER_FLAG = True
                    save_interrupt_context(mu)
                    mepc = int(mu.reg_read(UC_RISCV_REG_PC)) # pyright: ignore[reportArgumentType]
                    mu.mem_write(ADDRESS_MEPC, mepc.to_bytes(4, 'little'))
                    pc = ADDRESS_TIMER_INT

            if next_inst_mret(mu.mem_read(pc, 4)): # pyright: ignore[reportArgumentType]
                if DEBUG_MODE: print(f">>> Tracing instruction at {hex(pc)} \tmret\n")
                restore_interrupt_context(mu)
                mepc = mu.mem_read(ADDRESS_MEPC, 4)
                pc = int.from_bytes(mepc, 'little') 
                if TIMER_FLAG:
                    TIMER_FLAG = False
                if TIMER_SET:
                    TIMER_INTERRUPT_ENABLED = True

            mu.emu_start(begin=pc, until=pc+4, count=1) # type: ignore
            pc = mu.reg_read(UC_RISCV_REG_PC)

        DEBUG(f"\n>>> Emulation done.")
    except Exception as e:
        if DEBUG_MODE:
            print("\n\nregisters")
            for i in range(31):
                print(f"x{i} : ",mu.reg_read(i))
            print("PC", hex(mu.reg_read(UC_RISCV_REG_PC)))
            print("Flag timer int", TIMER_SET)
            print("Status timer int", TIMER_INTERRUPT_ENABLED)
        print(f"\n\n{e}")
    return file_output

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    main(sys.argv[1])
