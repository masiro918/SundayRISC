#define uint8_t unsigned char
#define uint32_t unsigned int
#define uint16_t unsigned short
#define size_t unsigned int
#define NULL sizeof(unsigned int)-1

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
