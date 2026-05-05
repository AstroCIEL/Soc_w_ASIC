/* An extremely minimalist syscalls.c for newlib
 * Based on riscv newlib libgloss/riscv/sys_*.c
 *
 * Copyright 2019 Claire Wolf
 * Copyright 2019 ETH Zürich and University of Bologna
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#include <sys/stat.h>
#include <sys/timeb.h>
#include <sys/times.h>
#include <sys/utime.h>
#include <unistd.h>
#include <machine/syscall.h>
#include "soc_ctrl.h"
#include "serial.h"
#include "context.h"

/* Define our own errno to avoid linking newlib's libc */
int errno;

/* errno constants - simplified definitions */
#define EPERM        1
#define ENOENT       2
#define ESRCH        3
#define EINTR        4
#define EIO          5
#define ENXIO        6
#define E2BIG        7
#define ENOEXEC      8
#define EBADF        9
#define ECHILD      10
#define EAGAIN      11
#define ENOMEM      12
#define EACCES      13
#define EFAULT      14
#define ENOTBLK     15
#define EBUSY       16
#define EEXIST      17
#define EXDEV       18
#define ENODEV      19
#define ENOTDIR     20
#define EISDIR      21
#define EINVAL      22
#define ENFILE      23
#define EMFILE      24
#define ENOTTY      25
#define ETXTBSY     26
#define EFBIG       27
#define ENOSPC      28
#define ESPIPE      29
#define EROFS       30
#define EMLINK      31
#define EPIPE       32
#define EDOM        33
#define ERANGE      34
#define ENOSYS      38
#define ENOTEMPTY   39

#define STDOUT_FILENO 1
#define STDERR_FILENO 2

/* System call wrapper - simplified version without newlib dependency */
long
__syscall_error(long a0)
{
  errno = -a0;
  return -1;
}

void unimplemented_syscall()
{
  uart0.puts(&uart0, "BSP: Unimplemented system call called!\n");
}

int nanosleep(const struct timespec *rqtp, struct timespec *rmtp)
{
  (void)rqtp; (void)rmtp;
  errno = ENOSYS;
  return -1;
}

int _access(const char *file, int mode)
{
  (void)file; (void)mode;
  errno = ENOSYS;
  return -1;
}

int _chdir(const char *path)
{
  (void)path;
  errno = ENOSYS;
  return -1;
}

int _chmod(const char *path, mode_t mode)
{
  (void)path; (void)mode;
  errno = ENOSYS;
  return -1;
}

int _chown(const char *path, uid_t owner, gid_t group)
{
  (void)path; (void)owner; (void)group;
  errno = ENOSYS;
  return -1;
}

int _close(int file)
{
  (void)file;
  return -1;
}

int _execve(const char *name, char *const argv[], char *const env[])
{
  (void)name; (void)argv; (void)env;
  errno = ENOMEM;
  return -1;
}

void _exit(int exit_status)
{
  soc_exit(exit_status);
}

int _faccessat(int dirfd, const char *file, int mode, int flags)
{
  (void)dirfd; (void)file; (void)mode; (void)flags;
  errno = ENOSYS;
  return -1;
}

int _fork(void)
{
  errno = EAGAIN;
  return -1;
}

int _fstat(int file, struct stat *st)
{
  (void)file;
  st->st_mode = S_IFCHR;
  return 0;
  // errno = -ENOSYS;
  // return -1;
}

int _fstatat(int dirfd, const char *file, struct stat *st, int flags)
{
  (void)dirfd; (void)file; (void)st; (void)flags;
  errno = ENOSYS;
  return -1;
}

int _ftime(struct timeb *tp)
{
  (void)tp;
  errno = ENOSYS;
  return -1;
}

char *_getcwd(char *buf, size_t size)
{
  (void)buf; (void)size;
  errno = -ENOSYS;
  return NULL;
}

int _getpid()
{
  return 1;
}

int _gettimeofday(struct timeval *tp, void *tzp)
{
  (void)tp; (void)tzp;
  errno = -ENOSYS;
  return -1;
}

int _isatty(int file)
{
  return (file == STDOUT_FILENO) || (file == STDERR_FILENO);
}

int _kill(int pid, int sig)
{
  (void)pid; (void)sig;
  errno = EINVAL;
  return -1;
}

int _link(const char *old_name, const char *new_name)
{
  (void)old_name; (void)new_name;
  errno = EMLINK;
  return -1;
}

off_t _lseek(int file, off_t ptr, int dir)
{
  (void)file; (void)ptr; (void)dir;
  return 0;
}

int _lstat(const char *file, struct stat *st)
{
  (void)file; (void)st;
  errno = ENOSYS;
  return -1;
}

int _open(const char *name, int flags, int mode)
{
  (void)name; (void)flags; (void)mode;
  return -1;
}

int _openat(int dirfd, const char *name, int flags, int mode)
{
  (void)dirfd; (void)name; (void)flags; (void)mode;
  errno = ENOSYS;
  return -1;
}

ssize_t _read(int file, void *ptr, size_t len)
{
  (void)file; (void)ptr; (void)len;
  return 0;
}

int _stat(const char *file, struct stat *st)
{
  (void)file;
  st->st_mode = S_IFCHR;
  return 0;
  // errno = ENOSYS;
  // return -1;
}

long _sysconf(int name)
{
  (void)name;
  return -1;
}

clock_t _times(struct tms *buf)
{
  (void)buf;
  return -1;
}

int _unlink(const char *name)
{
  (void)name;
  errno = ENOENT;
  return -1;
}

int _utime(const char *path, const struct utimbuf *times)
{
  (void)path; (void)times;
  errno = ENOSYS;
  return -1;
}

int _wait(int *status)
{
  (void)status;
  errno = ECHILD;
  return -1;
}

ssize_t _write(int file, const void *ptr, size_t len)
{
  const char *cptr = (char *)ptr;
  if (file != STDOUT_FILENO && file != STDERR_FILENO)
    {
      errno = ENOSYS;
      return -1;
    }

  const void *eptr = cptr + len;
  while (cptr != eptr)
    uart0.putc(&uart0, *cptr++);
  return len;
}

extern char __heap_start[];
extern char __heap_end[];
static char *brk = __heap_start;

int _brk(void *addr)
{
  brk = addr;
  return 0;
}

void *_sbrk(ptrdiff_t incr)
{
  char *old_brk = brk;
  long sp;
  __asm__ volatile ("mv %0, sp" : "=r"(sp));

  char *new_brk = brk += incr;
  if (new_brk < (char *) sp && new_brk < __heap_end)
    {
      brk = new_brk;

      return old_brk;
    }
  else
    {
      errno = ENOMEM;
      return (void *) -1;
    }
}

void handle_syscall(trap_context_t *ctx)
{
  long a0 = (long)ctx->gpr[REG_A0];
  long a1 = (long)ctx->gpr[REG_A1];
  long a2 = (long)ctx->gpr[REG_A2];
  long a3 = (long)ctx->gpr[REG_A3];
  long syscall_id = (long)ctx->gpr[REG_A7];

  long ret = -ENOSYS;
  switch (syscall_id) {
    case SYS_exit:
      _exit(a0);
      __builtin_unreachable();
    case SYS_read:
      ret = _read(a0, (void *)a1, a2);
      break;
    case SYS_write:
      ret = _write(a0, (const void *)a1, a2);
      break;
    case SYS_getpid:
      ret = _getpid();
      break;
    case SYS_kill:
      ret = _kill(a0, a1);
      break;
    case SYS_open:
      ret = _open((const char *)a0, a1, a2);
      break;
    case SYS_openat:
      ret = _openat(a0, (const char *)a1, a2, a3);
      break;
    case SYS_close:
      ret = _close(a0);
      break;
    case SYS_lseek:
      ret = _lseek(a0, a1, a2);
      break;
    case SYS_brk:
      ret = _brk((void *)a0);
      break;
    case SYS_link:
      ret = _link((const char *)a0, (const char *)a1);
      break;
    case SYS_unlink:
      ret = _unlink((const char *)a0);
      break;
    case SYS_chdir:
      ret = _chdir((const char *)a0);
      break;
    case SYS_getcwd:
      ret = (long)_getcwd((char *)a0, a1);
      break;
    case SYS_stat:
      ret = _stat((const char *)a0, (struct stat *)a1);
      break;
    case SYS_fstat:
      ret = _fstat(a0, (struct stat *)a1);
      break;
    case SYS_lstat:
      ret = _lstat((const char *)a0, (struct stat *)a1);
      break;
    case SYS_fstatat:
      ret = _fstatat(a0, (const char *)a1, (struct stat *)a2, a3);
      break;
    case SYS_access:
      ret = _access((const char *)a0, a1);
      break;
    case SYS_faccessat:
      ret = _faccessat(a0, (const char *)a1, a2, a3);
      break;
    case SYS_gettimeofday:
      ret = _gettimeofday((struct timeval *)a0, (void *)a1);
      break;
    case SYS_times:
      ret = _times((struct tms *)a0);
      break;
    default:
      unimplemented_syscall();
      break;
  }
  ctx->gpr[REG_A0] = (uint64_t)ret;
}

void ctx_advance_mepc(trap_context_t *ctx)
{
  uint16_t hw = *(const uint16_t *)(uintptr_t)ctx->mepc;
  ctx->mepc += ((hw & 0x3) == 0x3) ? 4 : 2;
}
