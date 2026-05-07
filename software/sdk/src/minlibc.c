/* Minimal libc stubs for ARA SoC to avoid LLD relocation issues with newlib.
 * This provides just enough functionality for basic printf and runtime.
 */

#include <stddef.h>
#include <string.h>
#include "serial.h"

/* errno stub */
int errno = 0;

/* External uart0 for output - defined in serial driver */
extern struct uart uart0;

/* memset implementation */
void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

/* memcpy implementation */
void *memcpy(void *dest, const void *src, size_t n) {
    unsigned char *d = dest;
    const unsigned char *s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

/* memmove implementation */
void *memmove(void *dest, const void *src, size_t n) {
    unsigned char *d = dest;
    const unsigned char *s = src;
    if (d < s) {
        while (n--) {
            *d++ = *s++;
        }
    } else {
        d += n;
        s += n;
        while (n--) {
            *--d = *--s;
        }
    }
    return dest;
}

/* strlen implementation */
size_t strlen(const char *s) {
    size_t len = 0;
    while (s[len]) {
        len++;
    }
    return len;
}

/* strcmp implementation */
int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(unsigned char *)s1 - *(unsigned char *)s2;
}

/* strncpy implementation */
char *strncpy(char *dest, const char *src, size_t n) {
    char *d = dest;
    const char *s = src;
    size_t i = 0;
    while (i < n && *s) {
        *d++ = *s++;
        i++;
    }
    while (i < n) {
        *d++ = '\0';
        i++;
    }
    return dest;
}

/* strncmp implementation */
int strncmp(const char *s1, const char *s2, size_t n) {
    if (n == 0) return 0;
    while (n-- && *s1 && (*s1 == *s2)) {
        s1++;
        s2++;
        if (n == 0) return 0;
    }
    return *(unsigned char *)s1 - *(unsigned char *)s2;
}

/* strchr implementation */
char *strchr(const char *s, int c) {
    while (*s) {
        if (*s == c) {
            return (char *)s;
        }
        s++;
    }
    return NULL;
}

/* exit - call the system exit to properly terminate simulation */
extern void _exit(int status);
void exit(int status) {
    _exit(status);
    __builtin_unreachable();
}

/* atexit - returns 0 (success) but does nothing (no cleanup needed) */
int atexit(void (*func)(void)) {
    (void)func;
    return 0;
}

/* __libc_init_array - does nothing (constructor array handled by crt0) */
void __libc_init_array(void) {
    // Constructor array already handled by crt0
}

/* __libc_fini_array - does nothing (destructor array not needed in embedded) */
void __libc_fini_array(void) {
    // Destructor array not needed in embedded
}

/* puts - write a string to stdout followed by a newline */
int puts(const char *s) {
    uart0.puts(&uart0, s);
    uart0.putc(&uart0, '\n');
    return 1;  // Return non-negative on success
}

/* putchar - output a single character to stdout */
int putchar(int c) {
    uart0.putc(&uart0, (char)c);
    return c;
}
