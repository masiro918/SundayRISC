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

class VirtHD():

    def __init__(self) -> None:
        """ 
        Virtual Hard Drive implementation for emulation purposes.

        This class simulates a block storage device with 512-byte sectors.
        It provides basic read/write operations and maintains device state.
        """

        self.__content = {}
        self.__status = 0
        self.__device_addr = 0

    def __do_read(self, block_count: int) -> bytes:
        result = b''
        for i in range(block_count):
            block_addr = self.__device_addr + i
            if block_addr in self.__content:
                result += self.__content[block_addr]
            else:
                result += b'\x00' * 512
        return result

    def __do_write(self, data: bytes):
        if (len(data) % 512) != 0:
            self.__status = 0
            raise Exception("Illegal data")
        
        # Saving the data
        for i in range(0, len(data), 512):
            block_addr = self.__device_addr + (i // 512)
            self.__content[block_addr] = data[i:i+512]


    def read_status(self):
        return self.__status
    
    def set_status(self, status: int):
        self.status = status

    def write(self, data: bytes, device_addr: int):
        """ Writes data into specific address. Data must be divide by 512. """

        if self.__status != 0:
            raise Exception("Device is busy.")
        
        self.__status = 1
        self.__device_addr = device_addr

        self.__do_write(data)
        self.__status = 0
        self.__device_addr = 0
        
    def read(self, device_addr: int, block_count: int) -> bytes:
        """ Reads specified number of blocks from device address. Each block is 512 bytes. """

        if self.__status != 0:
            raise Exception("Device is busy.")
        
        self.__status = 1
        self.__device_addr = device_addr

        data = self.__do_read(block_count)
        self.__status = 0
        self.__device_addr = 0
        return data

    def __str__(self):
        ret_str = ""
        for key in self.__content:
            value = self.__content[key]
            ret_str += f"\n<< {key} >>\n\t{value}\n"
        return ret_str

def write_file(file: str) -> VirtHD:
    """ Writes file into device from block 1 -> ... """

    hd=VirtHD()

    f=open(file, "rb")
    data=f.read().decode("utf-8", "ignore")
    f.close()

    blocks = []
    p = 0
    block = str()
    for c in data:
        if p == 512:
            blocks.append(block)
            block = str(c)
            p = 1
            continue
        block = block + c
        p=p+1

    for i in range(len(blocks)):
        hd.write(blocks[i], i*512)

    return hd

"""
hd=write_file("fs.bin")
print(hd.__str__())
"""
