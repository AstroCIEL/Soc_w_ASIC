/* Minimal system call stubs for newlib compatibility
 * These are required when linking against libc.a
 */

#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

#undef errno
extern int errno;

/* System call error stub */
long __syscall_error(long a0)
{
    errno = -a0;
    return -1;
}

/* File operations stubs */
int _close(int file)
{
    (void)file;
    return -1;
}

int _fstat(int file, struct stat *st)
{
    (void)file;
    st->st_mode = S_IFCHR;
    return 0;
}

int _isatty(int file)
{
    (void)file;
    return 1;
}

off_t _lseek(int file, off_t ptr, int dir)
{
    (void)file;
    (void)ptr;
    (void)dir;
    return 0;
}

ssize_t _read(int file, void *ptr, size_t len)
{
    (void)file;
    (void)ptr;
    (void)len;
    return 0;
}

ssize_t _write(int file, const void *ptr, size_t len)
{
    (void)file;
    (void)ptr;
    (void)len;
    return len;
}

/* Memory allocation stub */
void *_sbrk(ptrdiff_t incr)
{
    extern char __heap_start[];
    extern char __heap_end[];
    static char *heap_ptr = NULL;

    if (heap_ptr == NULL)
        heap_ptr = __heap_start;

    char *new_ptr = heap_ptr + incr;
    if (new_ptr > __heap_end) {
        errno = ENOMEM;
        return (void *)-1;
    }

    char *old_ptr = heap_ptr;
    heap_ptr = new_ptr;
    return old_ptr;
}

/* Exit stub - loop forever */
void _exit(int status)
{
    (void)status;
    while (1);
}

/* puts stub - use printf's _putchar via uart */
extern void _putchar(char c);
int puts(const char *s)
{
    while (*s) {
        _putchar(*s++);
    }
    _putchar('\n');
    return 0;
}

/* putchar stub */
int putchar(int c)
{
    _putchar((char)c);
    return c;
}

/* Get PID stub */
int _getpid(void)
{
    return 1;
}

/* Kill stub */
int _kill(int pid, int sig)
{
    (void)pid;
    (void)sig;
    errno = EINVAL;
    return -1;
}
