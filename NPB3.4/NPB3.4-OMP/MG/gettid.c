#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>

int gettid_() {
    return syscall(SYS_gettid);
}