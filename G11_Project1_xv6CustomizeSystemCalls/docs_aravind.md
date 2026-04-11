# IPC Message Passing in xv6-riscv

**Author:** Aravind Linga
**Project:** G11 — xv6 Customize System Calls  
**adm_no:** 24JE0645

---

## 1. Overview

This project implements **Inter-Process Communication (IPC)** via message passing in the xv6 operating system (RISC-V). Processes can create named mailboxes, send messages to other processes by mailbox name, and receive messages from their own mailbox. The design uses a kernel-managed, bounded circular buffer protected by spinlocks, with `sleep`/`wakeup` for blocking semantics.

---

## 2. System Calls Added

Five new system calls were added (syscall numbers 22–26):

| System Call | Signature | Description |
|---|---|---|
| `msgbox_create` | `int msgbox_create(char *name)` | Creates a named mailbox for the calling process. Returns 0 on success, -1 on error. |
| `msgbox_send` | `int msgbox_send(char *name, void *msg, int len)` | Sends `len` bytes to the mailbox identified by `name`. Blocks if the mailbox is full. Returns 0 on success. |
| `msgbox_recv` | `int msgbox_recv(void *buf, int maxlen)` | Receives a message into `buf` from the caller's own mailbox. Blocks if empty. Returns bytes read. |
| `msgbox_destroy` | `int msgbox_destroy(void)` | Destroys the caller's mailbox. Returns 0 on success. |
| `msgbox_count` | `int msgbox_count(void)` | Returns the number of pending messages in the caller's mailbox. |

---

## 3. Design Details

### 3.1 Data Structures

```c
// Constants (kernel/param.h)
#define MSGBOX_NAME  16    // max mailbox name length
#define MSG_SIZE     64    // max bytes per message
#define MSG_SLOTS     8    // max messages buffered per mailbox

// A single message (kernel/proc.h)
struct msg {
  char data[MSG_SIZE];
  int len;
};


struct msgbox {
  char name[MSGBOX_NAME];
  struct msg msgs[MSG_SLOTS]; 
  int head;                   
  int tail;                  
  int count;                  
  int active;                 
  struct spinlock lock;
};
```

Each `struct proc` contains a `struct msgbox mbox` field. A process must call `msgbox_create()` before it can receive messages.

### 3.2 Circular Buffer

Messages are stored in a fixed-size circular buffer of 8 slots:

```
  head                    tail
   |                       |
   v                       v
 [msg0] [msg1] [msg2] [ ] [ ] [ ] [ ] [ ]
  ^^^^^^^^^^^^^^^^^^^^
     3 messages queued (count = 3)
```

- **Send** writes at `tail`, increments `tail = (tail + 1) % MSG_SLOTS`
- **Receive** reads from `head`, increments `head = (head + 1) % MSG_SLOTS`
- **Full**: `count == MSG_SLOTS` → sender sleeps
- **Empty**: `count == 0` → receiver sleeps

### 3.3 Synchronization

- Each mailbox has its own **spinlock** (`mbox.lock`) to protect concurrent access
- **Blocking send**: if the mailbox is full, the sender calls `sleep()` on the `tail` address and is woken by `wakeup()` when the receiver dequeues a message
- **Blocking receive**: if the mailbox is empty, the receiver calls `sleep()` on the `head` address and is woken by `wakeup()` when a sender enqueues a message

### 3.4 Process Lifecycle

- **`allocproc()`** — initializes `mbox` fields to zero, calls `initlock()` on the mailbox spinlock
- **`freeproc()`** — resets all `mbox` fields (active=0, counters zeroed, name cleared)

---

## 4. Files Modified / Created

| File | Change |
|---|---|
| `kernel/param.h` | Added `MSGBOX_NAME`, `MSG_SIZE`, `MSG_SLOTS` constants |
| `kernel/proc.h` | Added `struct msg`, `struct msgbox`, and `mbox` field in `struct proc` |
| `kernel/proc.c` | Initialize mbox in `allocproc()`, reset in `freeproc()` |
| `kernel/ipc.c` | **[NEW]** Core IPC implementation (~200 lines) |
| `kernel/defs.h` | Added declarations for 5 IPC functions |
| `kernel/sysproc.c` | Added 5 `sys_msgbox_*` handler functions |
| `kernel/syscall.h` | Added syscall numbers 22–26 |
| `kernel/syscall.c` | Added extern declarations and dispatch table entries |
| `user/usys.pl` | Added 5 stub entries for user-space syscall wrappers |
| `user/user.h` | Added 5 function prototypes |
| `user/msgbox_test.c` | **[NEW]** Bidirectional parent-child test |
| `user/msgbox_demo.c` | **[NEW]** Simple send/receive demo |
| `Makefile` | Added `ipc.o`, `_msgbox_test`, `_msgbox_demo` |

---

## 5. Test Programs

### 5.1 msgbox_test

Bidirectional message exchange between parent and child:

1. Parent creates mailbox `"parent"`
2. Child creates mailbox `"child"`
3. Child sends `"hello from child"` → parent's mailbox
4. Parent receives and prints it
5. Parent sends `"hello from parent"` → child's mailbox
6. Child receives and prints it
7. Both destroy their mailboxes

### 5.2 msgbox_demo

Simple one-shot demo:

1. Parent creates mailbox `"box1"`
2. Child sends `"hi from child!"` → parent's mailbox
3. Parent receives and prints it

---

## 6. Output

```
xv6 kernel is booting

hart 1 starting
hart 2 starting
init: starting sh
$ msgbox_test
=== IPC Message Box Test ===

[parent] created mailbox 'parent'
[child]  created mailbox 'child'
[child]  sent: "hello from child"
[parent] received: "hello from child" (17 bytes)
[parent] sent: "hello from parent"
[child]  received: "hello from parent" (18 bytes)
[child]  pending messages: 0
[child]  destroyed mailbox
[parent] destroyed mailbox

=== All tests passed! ===
$ msgbox_demo
=== IPC Demo ===
[child]  sent message
[parent] got: "hi from child!" (15 bytes)
[parent] pending: 0
=== Done ===
```

## 7. How to Build and Run

```bash
# Build and launch xv6 in QEMU
make clean
make qemu

# Inside the xv6 shell:
$ msgbox_test
$ msgbox_demo
```


## 8. Limitations and Future Work

- **Blocking only**: `send` blocks when full, `recv` blocks when empty. Non-blocking variants could be added.
- **Unique names**: No two processes can share the same mailbox name.
- **Fixed message size**: Messages are capped at 64 bytes. Larger payloads would need multiple sends.
- **Per-process mailbox**: Each process can own only one mailbox at a time.
- **No persistence**: Mailboxes are destroyed when the owning process exits.
