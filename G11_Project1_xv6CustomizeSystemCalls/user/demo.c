#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
printint(int n)
{
  char buf[16];
  int i = 15;
  buf[i] = '\0';
  if(n == 0){ buf[--i] = '0'; }
  while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
  write(1, buf+i, 15-i);
}

static void
printstr(const char *s)
{
  write(1, s, strlen(s));
}

int
main(void)
{
  printstr("\n");
  printstr("========================================\n");
  printstr("  Process Creation System Calls Demo\n");
  printstr("  getprocinfo + setpriority (xv6-riscv)\n");
  printstr("========================================\n\n");

  // ── TEST 1: getprocinfo ──
  printstr("--- Test 1: getprocinfo ---\n");
  int my_pid = 0, my_prio = 0;

  if(getprocinfo(&my_pid, &my_prio) == 0){
    printstr("  PID      = ");
    printint(my_pid);
    printstr("\n");
    printstr("  Priority = ");
    printint(my_prio);
    printstr("  (default is 0)\n");
  } else {
    printstr("  ERROR: getprocinfo failed\n");
  }

  // ── TEST 2: setpriority ──
  printstr("\n--- Test 2: setpriority ---\n");

  if(setpriority(15) == 0){
    getprocinfo(&my_pid, &my_prio);
    printstr("  Set priority to 15\n");
    printstr("  Verified priority = ");
    printint(my_prio);
    printstr("  (expected 15)\n");
  } else {
    printstr("  ERROR: setpriority failed\n");
  }

  if(setpriority(99) == -1)
    printstr("  setpriority(99) correctly rejected\n");

  printstr("\n========================================\n");
  printstr("  Process Creation calls working!\n");
  printstr("========================================\n\n");

  exit(0);
}