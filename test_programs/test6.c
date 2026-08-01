#define uint8_t unsigned char
#define uint32_t unsigned int
#define uint16_t unsigned short
#define size_t unsigned int
#define NULL sizeof(unsigned int)-1

#define MMIO_BASE (uint32_t) 0x200000
#define SCREEN_TX (uint32_t) 0x200000

#include "stdlib.c"

uint8_t response[8000];

void mem_write(unsigned int addr, unsigned char val) {
    __asm__ __volatile__(
        "sb %1, 0(%0)"
        :
        : "r"(addr), "r"(val)
        : "memory"
    );
}

char mem_read(unsigned int addr) {
    char result;
    __asm__ __volatile__(
        "lb %0, 0(%1)"
        : "=r"(result)
        : "r"(addr)
        : "memory"
    );
    return result;
}

void putc(uint8_t c) {
   mem_write(SCREEN_TX, c);
}

void puts(uint8_t* str) {
    int ptr = 0;

    while (str[ptr] != '\0') {

        if (ptr >= 7999) break;
        putc(str[ptr]);
        ptr++;
    }
}

void puts_raw(const char* s) {
    while (*s) {
        putc(*s++);
    }
}

#define NET_TX (uint32_t)0x200004
#define NET_RX (uint32_t)0x200008
#define NET_RX_STATUS (uint32_t)0x20000B


int network_http_get_readme(int out_cap) {
    char frame[] = { 
        255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 8, 0, 69, 0, 0, 85, 0, 1, 0, 0, 64, 6, 124, 160, 127, 0, 0, 1, 127, 0, 0, 1, 0, 20, 31, 64, 0, 0, 0, 0, 0, 0, 0, 0, 80, 2, 32, 0, 227, 38, 0, 0, 71, 69, 84, 32, 47, 82, 69, 65, 68, 77, 69, 46, 109, 100, 32, 72, 84, 84, 80, 47, 49, 46, 48, 10, 72, 111, 115, 116, 58, 32, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 56, 48, 48, 48, 10, 13, 10, 13, 10
    };

    for (uint32_t i = 0; i < sizeof(frame); i++) {
        mem_write(NET_TX, frame[i]);
    }

    int n = 0;
    while (n < out_cap - 1) {

        if (NET_RX_STATUS == 0) {
            break;
        }

        uint8_t c = mem_read(NET_RX);

        if ((c >= 32 && c <= 126) || c == 10 || c == 13 || c == 9)
            response[n] = c;
        n++;
    }

    response[n] = '\0';
    return n;
}

void main(void) {
    int n = network_http_get_readme(8000);
    puts_raw("OK\n");
    
    if (n < 0) {
        puts_raw("[proc2] network error\n");
    } else {
        int i = 0;
        while (i < 7999) {
            putc(response[i]);
            i++;
        }
    }
}