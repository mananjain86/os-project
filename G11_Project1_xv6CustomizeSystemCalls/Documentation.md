# Project 1: Customizing System Calls in xv6

## Group 11

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Project Overview](#2-project-overview)
3. [System Calls Implemented](#3-system-calls-implemented)
   - 3.1 [getprocinfo](#31-getprocinfo)
   - 3.2 [setpriority](#32-setpriority)
   - 3.3 [thread_create](#33-thread_create)
   - 3.4 [thread_join](#34-thread_join)
   - 3.5 [shmcreate](#35-shmcreate---shared-memory-create)
   - 3.6 [shmat](#36-shmat---shared-memory-attach)
   - 3.7 [shmdt](#37-shmdt---shared-memory-detach)
4. [Implementation Details – Shared Memory IPC](#4-implementation-details--shared-memory-ipc)
   - 4.1 [Architecture](#41-architecture)
   - 4.2 [Data Structures](#42-data-structures)
   - 4.3 [Kernel Modifications](#43-kernel-modifications)
   - 4.4 [System Call Registration](#44-system-call-registration)
   - 4.5 [Process Lifecycle Handling](#45-process-lifecycle-handling)
5. [User Programs](#5-user-programs)
6. [Files Modified / Created](#6-files-modified--created)
7. [How to Build and Run](#7-how-to-build-and-run)
8. [Expected Output](#8-expected-output)
9. [Commit History](#9-commit-history)

---

## 1. Introduction

The xv6 operating system is a simplified Unix-like teaching OS developed at MIT. It runs on the RISC-V architecture and provides a minimal but functional kernel with support for processes, virtual memory, file systems, and basic system calls.

This project extends xv6 by implementing custom system calls covering process management, inter-process communication (IPC) via shared memory, and threading support.

---

## 2. Project Overview

The goal of this project is to:

- **Analyze** the existing xv6 system call infrastructure.
- **Implement** new system calls spanning multiple OS functionalities.
- **Demonstrate** their usage through user-level test programs.
- **Document** the work with code explanations and execution screenshots.

We implemented **7 new system calls** organized into the following categories:

| Category               | System Calls                   |
|------------------------|--------------------------------|
| Process Information    | `getprocinfo`, `setpriority`   |
| Threading              | `thread_create`, `thread_join` |
| Shared Memory IPC      | `shmcreate`, `shmat`, `shmdt`  |

---

## 3. System Calls Implemented

### 3.1 `getprocinfo`

**Prototype:**
```c
int getprocinfo(int *pid_out, int *priority_out);
```

**Description:**
Retrieves the PID and priority of the calling process and copies them to the provided user-space addresses.

**Implementation File:** `kernel/sysproc.c`

**Key Logic:**
- Uses `copyout()` to safely write kernel data (`p->pid`, `p->priority`) to user-space buffers.

---

### 3.2 `setpriority`

**Prototype:**
```c
int setpriority(int priority);
```

**Description:**
Sets the priority of the calling process. The priority value must be in the range `[0, 19]`.

**Implementation File:** `kernel/sysproc.c`

**Key Logic:**
- Reads the priority argument from the trapframe register `a0`.
- Validates the range and updates `p->priority`.

---

### 3.3 `thread_create`

**Prototype:**
```c
int thread_create(void (*fn)(void*), void *arg);
```

**Description:**
Creates a lightweight thread that shares the parent's address space. The thread begins execution at the specified function `fn` with argument `arg`.

**Implementation File:** `kernel/sysproc_thread.c`

**Key Logic:**
- Allocates a new process structure using `kallocproc()`.
- Shares the parent's page table (no `uvmcopy`) instead of duplicating it.
- Sets the program counter (`epc`) to the function pointer and passes the argument via register `a0`.
- Marks the process as a thread via `np->is_thread = 1`.

---

### 3.4 `thread_join`

**Prototype:**
```c
int thread_join(int tid);
```

**Description:**
Waits for the thread identified by `tid` to finish and reclaims its resources.

**Implementation File:** `kernel/sysproc_thread.c`

**Key Logic:**
- Iterates the process table looking for a thread with the matching `tid`.
- If the thread is in ZOMBIE state, it calls `kfreeproc()` to reclaim.
- If the thread is still running, it yields the CPU and retries.

---

### 3.5 `shmcreate` — Shared Memory Create

**Prototype:**
```c
int shmcreate(int key);
```

**Description:**
Creates a new shared memory segment identified by `key`, or returns the existing segment's ID if one with the same key already exists. A full physical page (4096 bytes) is allocated for each new segment.

**Implementation File:** `kernel/shm.c`

**Returns:** A shared memory ID (`shmid`) on success, `-1` on failure.

**Key Logic:**
```c
uint64 sys_shmcreate(void) {
  int key;
  argint(0, &key);

  acquire(&shm_lock);

  // Check if segment already exists
  for (int i = 0; i < SHM_MAX; i++) {
    if (shm_table[i].key == key && shm_table[i].pa != 0) {
      release(&shm_lock);
      return i;
    }
  }

  // Find an empty slot and allocate
  for (int i = 0; i < SHM_MAX; i++) {
    if (shm_table[i].pa == 0) {
      uint64 pa = (uint64)kalloc();
      if (pa == 0) { release(&shm_lock); return -1; }
      memset((void*)pa, 0, PGSIZE);
      shm_table[i].key = key;
      shm_table[i].pa = pa;
      shm_table[i].ref_count = 0;
      release(&shm_lock);
      return i;
    }
  }

  release(&shm_lock);
  return -1;
}
```

---

### 3.6 `shmat` — Shared Memory Attach

**Prototype:**
```c
uint64 shmat(int shmid);
```

**Description:**
Attaches the shared memory segment identified by `shmid` to the calling process's virtual address space. The kernel maps the segment's physical page into the process's page table at the next available virtual address above `p->sz`.

**Implementation File:** `kernel/shm.c`

**Returns:** The virtual address where the segment was mapped, or `-1` on failure.

**Key Logic:**
```c
uint64 sys_shmat(void) {
  int shmid;
  argint(0, &shmid);

  if (shmid < 0 || shmid >= SHM_MAX) return -1;

  acquire(&shm_lock);
  if (shm_table[shmid].pa == 0) { release(&shm_lock); return -1; }

  struct proc *p = myproc();
  uint64 va = PGROUNDUP(p->sz);

  // Map the shared physical page into the process's page table
  if (mappages(p->pagetable, va, PGSIZE, shm_table[shmid].pa,
               PTE_W | PTE_R | PTE_U) < 0) {
    release(&shm_lock);
    return -1;
  }

  shm_table[shmid].ref_count++;
  p->sz = va + PGSIZE;
  release(&shm_lock);
  return va;
}
```

---

### 3.7 `shmdt` — Shared Memory Detach

**Prototype:**
```c
int shmdt(int shmid);
```

**Description:**
Detaches the shared memory segment from the calling process. If no other process is attached, the physical memory is freed. The kernel walks the process's page table to find the mapping and uses `uvmunmap()` to remove it without freeing the underlying physical page (which may still be in use by other processes).

**Implementation File:** `kernel/shm.c`

**Returns:** `0` on success, `-1` on failure.

**Key Logic:**
```c
uint64 sys_shmdt(void) {
  int shmid;
  argint(0, &shmid);

  if (shmid < 0 || shmid >= SHM_MAX) return -1;

  acquire(&shm_lock);
  if (shm_table[shmid].pa == 0) { release(&shm_lock); return -1; }

  struct proc *p = myproc();
  // Walk page table to find the VA mapped to this shared PA
  for (uint64 a = 0; a < p->sz; a += PGSIZE) {
    pte_t *pte = walk(p->pagetable, a, 0);
    if (pte != 0 && (*pte & PTE_V) && PTE2PA(*pte) == shm_table[shmid].pa) {
      uvmunmap(p->pagetable, a, 1, 0); // Unmap only, don't free PA
      break;
    }
  }

  shm_table[shmid].ref_count--;
  if (shm_table[shmid].ref_count <= 0) {
    kfree((void*)shm_table[shmid].pa);
    shm_table[shmid].pa = 0;
    shm_table[shmid].key = 0;
    shm_table[shmid].ref_count = 0;
  }

  release(&shm_lock);
  return 0;
}
```

---

## 4. Implementation Details – Shared Memory IPC

### 4.1 Architecture

The shared memory subsystem enables two or more processes to share a region of physical memory. The key idea is that multiple processes can map the **same physical page** into their own **independent virtual address spaces**.

```
  Process A (VA Space)        Physical Memory        Process B (VA Space)
  +------------------+       +--------------+       +------------------+
  |                  |       |              |       |                  |
  |  VA 0x5000 ------+------>| PA 0x87654  |<------+-- VA 0x6000      |
  |                  |       |  (Shared)    |       |                  |
  +------------------+       +--------------+       +------------------+
```

### 4.2 Data Structures

Defined in `kernel/shm.h`:

```c
#define SHM_MAX 64

struct shm_table_entry {
  int key;               // Unique key to identify the shared memory segment
  uint64 pa;             // Physical address of the allocated page
  int ref_count;         // Number of processes currently attached
  struct spinlock lock;  // Per-entry lock
};
```

Global state in `kernel/shm.c`:

```c
struct spinlock shm_lock;                    // Global table lock
struct shm_table_entry shm_table[SHM_MAX];   // Shared memory table
```

### 4.3 Kernel Modifications

| File | Change |
|------|--------|
| `kernel/shm.h` | **[NEW]** Shared memory data structures and constants |
| `kernel/shm.c` | **[NEW]** Core implementation: `shminit()`, `sys_shmcreate()`, `sys_shmat()`, `sys_shmdt()`, `shm_release()` |
| `kernel/main.c` | Added `shminit()` call during boot |
| `kernel/defs.h` | Added declarations for `shminit()` and `shm_release()` |
| `kernel/proc.c` | Modified `freeproc()` to call `shm_release()` before freeing page table |
| `kernel/syscall.h` | Added syscall numbers 26, 27, 28 |
| `kernel/syscall.c` | Added extern declarations and dispatch table entries |
| `user/usys.pl` | Added `entry("shmcreate")`, `entry("shmat")`, `entry("shmdt")` |
| `user/user.h` | Added user-space function prototypes |
| `Makefile` | Added `$K/shm.o` to OBJS and `$U/_shmtest` to UPROGS |

### 4.4 System Call Registration

The three shared memory system calls are registered with the following numbers:

```c
// kernel/syscall.h
#define SYS_shmcreate 26
#define SYS_shmat     27
#define SYS_shmdt     28
```

The dispatch table in `kernel/syscall.c`:

```c
[SYS_shmcreate] sys_shmcreate,
[SYS_shmat]     sys_shmat,
[SYS_shmdt]     sys_shmdt,
```

### 4.5 Process Lifecycle Handling

When a process exits or is killed, any attached shared memory segments must be properly cleaned up. The `shm_release()` function is called from `freeproc()` in `kernel/proc.c`:

```c
static void freeproc(struct proc *p) {
  // ... existing cleanup ...
  if(p->pagetable) {
    shm_release(p->pagetable, p->sz);   // <-- Added
    proc_freepagetable(p->pagetable, p->sz);
  }
  // ...
}
```

`shm_release()` iterates through all shared memory segments and checks if any are mapped in the dying process's page table. If found, it unmaps them and decrements the reference count, freeing the physical page if no other process holds a reference.

---

## 5. User Programs

### `shmtest` — Shared Memory Test Program

**File:** `user/shmtest.c`

This program demonstrates inter-process communication using shared memory:

1. The parent process creates a shared memory segment with key `1234`.
2. It forks a child process.
3. The **child** attaches to the shared memory and writes a message: `"Hello from child process via SHM!"`.
4. The child detaches and exits.
5. The **parent** waits for the child, attaches to the same segment, and reads the message.
6. The parent prints the message and detaches.

```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  printf("Starting Shared Memory Test...\n");

  int shmid = shmcreate(1234);
  if (shmid < 0) { printf("shmcreate failed\n"); exit(1); }

  int pid = fork();
  if (pid < 0) { printf("fork failed\n"); exit(1); }

  if (pid == 0) {
    // Child: write to shared memory
    char *shm_ptr = (char*)shmat(shmid);
    printf("Child: Writing to shared memory...\n");
    strcpy(shm_ptr, "Hello from child process via SHM!");
    shmdt(shmid);
    exit(0);
  } else {
    // Parent: read from shared memory
    wait(0);
    char *shm_ptr = (char*)shmat(shmid);
    printf("Parent: Read from shared memory: '%s'\n", shm_ptr);
    shmdt(shmid);
  }

  printf("Shared Memory Test completed successfully.\n");
  exit(0);
}
```

---

## 6. Files Modified / Created

| File | Status | Description |
|------|--------|-------------|
| `kernel/shm.h` | **NEW** | Shared memory structures and constants |
| `kernel/shm.c` | **NEW** | Full shared memory implementation |
| `user/shmtest.c` | **NEW** | User test program for shared memory |
| `kernel/main.c` | Modified | Added `shminit()` during boot |
| `kernel/defs.h` | Modified | Added function declarations |
| `kernel/proc.c` | Modified | Added `shm_release()` call in `freeproc()` |
| `kernel/syscall.h` | Modified | Added syscall numbers 26–28 |
| `kernel/syscall.c` | Modified | Added extern + dispatch entries |
| `user/usys.pl` | Modified | Added syscall stubs |
| `user/user.h` | Modified | Added user-space prototypes |
| `Makefile` | Modified | Added `shm.o` and `_shmtest` |

---

## 7. How to Build and Run

### Prerequisites
- RISC-V cross-compilation toolchain (`riscv64-unknown-elf-gcc` or equivalent)
- QEMU with RISC-V support (`qemu-system-riscv64`)

### Build and Boot

```bash
cd G11_Project1_xv6CustomizeSystemCalls
make clean
make qemu
```

### Run the Shared Memory Test

Once the xv6 shell boots, run:

```
$ shmtest
```

---

## 8. Expected Output

```
Starting Shared Memory Test...
Child: Writing to shared memory...
Parent: Read from shared memory: 'Hello from child process via SHM!'
Shared Memory Test completed successfully.
```

> **Note:** Attach a screenshot of the actual QEMU execution output here for your submission.

---

## 9. Commit History

The shared memory implementation was developed incrementally across 7 commits:

| # | Commit Message | Description |
|---|----------------|-------------|
| 1 | Add Shared Memory Core Structures & Initialization | Created `shm.h`, `shm.c`, added `shminit()` to boot |
| 2 | Implement sys_shmcreate | Segment creation/lookup by key, `kalloc()` allocation |
| 3 | Implement sys_shmat (Attach) | Map shared PA into process VA via `mappages()` |
| 4 | Implement sys_shmdt (Detach) | Unmap VA, decrement refcount, free if last |
| 5 | Register System Calls in xv6 | Wired syscalls in `syscall.h/c`, `usys.pl`, `user.h` |
| 6 | Handle Process Lifecycle | `shm_release()` on process exit in `freeproc()` |
| 7 | Create User Test Program & Makefile | `shmtest.c` and Makefile integration |

---
