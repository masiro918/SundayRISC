#define uint8_t unsigned char
#define uint32_t unsigned int
#define uint16_t unsigned short
#define size_t unsigned int
#define NULL sizeof(unsigned int)-1

#define MMIO_BASE (uint32_t) 0x200000
#define SCREEN_TX (uint32_t) 0x200000

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

// Simple malloc implementation using static buffer
#define HEAP_SIZE 10240
static char heap[HEAP_SIZE];
static size_t heap_ptr = 0;

void* malloc(size_t size) {
    // Align to 8 bytes
    size_t aligned_size = (size + 7) & ~7;

    if (heap_ptr + aligned_size > HEAP_SIZE) {
        return NULL;
    }

    void* ptr = &heap[heap_ptr];
    heap_ptr += aligned_size;
    return ptr;
}

// String copy
char* strcpy(char* dest, const char* src) {
    char* orig_dest = dest;
    while ((*dest++ = *src++) != '\0');
    return orig_dest;
}

// String compare
int strcmp(const char* s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return (unsigned char)*s1 - (unsigned char)*s2;
}

// String concatenate
char* strcat(char* dest, const char* src) {
    char* orig_dest = dest;
    while (*dest) dest++;
    while ((*dest++ = *src++) != '\0');
    return orig_dest;
}

// Memory copy
void* memcpy(void* dest, const void* src, size_t n) {
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

// ASCII to integer
int atoi(const char* str) {
    int result = 0;
    int sign = 1;

    // Skip whitespace
    while (*str == ' ' || *str == '\t' || *str == '\n') {
        str++;
    }

    // Handle sign
    if (*str == '-') {
        sign = -1;
        str++;
    } else if (*str == '+') {
        str++;
    }

    // Convert digits
    while (*str >= '0' && *str <= '9') {
        result = result * 10 + (*str - '0');
        str++;
    }

    return sign * result;
}

// Integer to string conversion
char* int_to_str(int value) {
    static char buf[12]; // -2147483648\0
    int i = 11;
    unsigned int magnitude;
    int is_negative = 0;

    buf[i] = '\0';

    if (value == 0) {
        buf[--i] = '0';
        return &buf[i];
    }

    if (value < 0) {
        is_negative = 1;
        magnitude = (unsigned int)(~(unsigned int)value) + 1;
    } else {
        magnitude = (unsigned int)value;
    }

    while (magnitude > 0 && i > 0) {
        buf[--i] = (char)('0' + (magnitude % 10));
        magnitude /= 10;
    }

    if (is_negative && i > 0) {
        buf[--i] = '-';
    }

    return &buf[i];
}

// Memory set
void* memset(void* dest, int c, size_t n) {
    unsigned char* d = (unsigned char*)dest;
    unsigned char value = (unsigned char)c;
    while (n--) {
        *d++ = value;
    }
    return dest;
}

int network_http_get_readme(int out_cap) {
    char frame[] = { 
        255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 8, 0, 69, 0, 0, 89, 0, 1, 0, 0, 64, 6, 124, 156, 127, 0, 0, 1, 127, 0, 0, 1, 0, 20, 31, 64, 0, 0, 0, 0, 0, 0, 0, 0, 80, 2, 32, 0, 162, 81, 0, 0, 71, 69, 84, 32, 47, 103, 101, 116, 63, 102, 111, 111, 61, 98, 97, 114, 32, 72, 84, 84, 80, 47, 49, 46, 49, 10, 72, 111, 115, 116, 58, 32, 112, 111, 115, 116, 109, 97, 110, 45, 101, 99, 104, 111, 46, 99, 111, 109, 10, 13, 10, 13, 10
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