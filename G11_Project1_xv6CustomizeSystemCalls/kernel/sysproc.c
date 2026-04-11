#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// IPC message box system calls

uint64
sys_msgbox_create(void)
{
  char name[MSGBOX_NAME];
  if(argstr(0, name, MSGBOX_NAME) < 0)
    return -1;
  return msgbox_create_impl(name);
}

uint64
sys_msgbox_send(void)
{
  char name[MSGBOX_NAME];
  uint64 addr;
  int len;
  char buf[MSG_SIZE];

  if(argstr(0, name, MSGBOX_NAME) < 0)
    return -1;
  argaddr(1, &addr);
  argint(2, &len);
  if(len <= 0 || len > MSG_SIZE)
    return -1;
  if(copyin(myproc()->pagetable, buf, addr, len) < 0)
    return -1;
  return msgbox_send_impl(name, buf, len);
}

uint64
sys_msgbox_recv(void)
{
  uint64 addr;
  int maxlen;
  char buf[MSG_SIZE];
  int len;

  argaddr(0, &addr);
  argint(1, &maxlen);
  if(maxlen <= 0 || maxlen > MSG_SIZE)
    return -1;
  len = msgbox_recv_impl(buf, maxlen);
  if(len < 0)
    return -1;
  if(copyout(myproc()->pagetable, addr, buf, len) < 0)
    return -1;
  return len;
}

uint64
sys_msgbox_destroy(void)
{
  return msgbox_destroy_impl();
}

uint64
sys_msgbox_count(void)
{
  return msgbox_count_impl();
}
