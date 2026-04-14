// #include "kernel/types.h"
// #include "kernel/stat.h"
// #include "user/user.h"

// static void
// printint(int n)
// {
//   char buf[16];
//   int i = 15;
//   buf[i] = '\0';
//   if(n == 0){ buf[--i] = '0'; }
//   while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
//   write(1, buf+i, 15-i);
// }

// static void
// printstr(const char *s)
// {
//   write(1, s, strlen(s));
// }

// int
// main(void)
// {
//   // printstr("\n");
//   // printstr("========================================\n");
//   // printstr("  Process Creation System Calls Demo\n");
//   // printstr("  getprocinfo + setpriority (xv6-riscv)\n");
//   // printstr("========================================\n\n");

//   // ── TEST 1: getprocinfo ──
//   printstr("--- Test 1: getprocinfo ---\n");
//   int my_pid = 0, my_prio = 0;

//   if(getprocinfo(&my_pid, &my_prio) == 0){
//     printstr("  PID      = ");
//     printint(my_pid);
//     printstr("\n");
//     printstr("  Priority = ");
//     printint(my_prio);
//     printstr("  (default is 0)\n");
//   } else {
//     printstr("  ERROR: getprocinfo failed\n");
//   }

//   // ── TEST 2: setpriority ──
//   printstr("\n--- Test 2: setpriority ---\n");

//   if(setpriority(15) == 0){
//     getprocinfo(&my_pid, &my_prio);
//     printstr("  Set priority to 15\n");
//     printstr("  Verified priority = ");
//     printint(my_prio);
//     printstr("  (expected 15)\n");
//   } else {
//     printstr("  ERROR: setpriority failed\n");
//   }

//   if(setpriority(99) == -1)
//     printstr("  setpriority(99) correctly rejected\n");

//   // printstr("\n========================================\n");
//   // printstr("  Process Creation calls working!\n");
//   // printstr("========================================\n\n");

//   exit(0);
// }

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// ── Print an integer to screen ───────────────────────────────
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

// ── Print a string to screen ─────────────────────────────────
static void
printstr(const char *s)
{
  write(1, s, strlen(s));
}

// ── Read a line of input from user ───────────────────────────
static int
readline(char *buf, int max)
{
  int i = 0;
  char c;
  while(i < max - 1){
    int n = read(0, &c, 1);  // read one character from stdin
    if(n <= 0) break;
    if(c == '\n' || c == '\r') break;
    buf[i++] = c;
  }
  buf[i] = '\0';
  return i;
}

// ── Convert string to integer ────────────────────────────────
static int
strtonum(char *s)
{
  int n = 0;
  int neg = 0;
  if(*s == '-'){ neg = 1; s++; }
  while(*s >= '0' && *s <= '9'){
    n = n * 10 + (*s - '0');
    s++;
  }
  return neg ? -n : n;
}

// ── Print menu ───────────────────────────────────────────────
static void
print_menu(void)
{
  // printstr("\n========================================\n");
  // printstr("  Process Creation System Calls Demo\n");
  // printstr("  xv6-riscv\n");
  // printstr("========================================\n");
  printstr("  1. getprocinfo  - Get PID and Priority\n");
  printstr("  2. setpriority  - Set Priority\n");
  printstr("  3. Exit\n");
  // printstr("========================================\n");
  printstr("Enter choice: ");
}

int
main(void)
{
  char buf[32];
  int choice;

  printstr("\n");
  // printstr("  Welcome to Process Creation Demo\n");
  // printstr("  (xv6-riscv System Calls)\n");

  while(1){

    // Show menu and get choice
    print_menu();
    readline(buf, sizeof(buf));
    choice = strtonum(buf);

    // ── OPTION 1: getprocinfo ──────────────────────────────
    if(choice == 1){
      printstr("\n--- getprocinfo ---\n");

      int my_pid = 0, my_prio = 0;

      if(getprocinfo(&my_pid, &my_prio) == 0){
        printstr("  Current PID      = ");
        printint(my_pid);
        printstr("\n");
        printstr("  Current Priority = ");
        printint(my_prio);
        printstr("\n");
      } else {
        printstr("  ERROR: getprocinfo failed\n");
      }

    // ── OPTION 2: setpriority ──────────────────────────────
    } else if(choice == 2){
      printstr("\n--- setpriority ---\n");
      printstr("  Enter priority (0 = lowest, 19 = highest): ");

      readline(buf, sizeof(buf));
      int prio = strtonum(buf);

      printstr("  Trying to set priority to ");
      printint(prio);
      printstr("...\n");

      if(setpriority(prio) == 0){
        // Verify by reading back with getprocinfo
        int my_pid = 0, my_prio = 0;
        getprocinfo(&my_pid, &my_prio);
        printstr("  Success! Priority is now = ");
        printint(my_prio);
        printstr("\n");
      } else {
        printstr("  ERROR: ");
        printint(prio);
        printstr(" is invalid. Must be between 0 and 19.\n");
      }

    // ── OPTION 3: Exit ────────────────────────────────────
    } else if(choice == 3){
      printstr("\n  Exiting demo. Goodbye!\n\n");
      exit(0);

    // ── Invalid choice ────────────────────────────────────
    } else {
      printstr("\n  Invalid choice. Please enter 1, 2 or 3.\n");
    }

  }

  exit(0);
}