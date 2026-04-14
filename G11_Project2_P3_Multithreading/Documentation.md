# Project 2: Multithreaded File Management System
**Focus Areas:** File Copying and File Metadata Display
**Team Member Role Documentation**

---

## 1. Objective
The goal of this project is to implement a multithreaded file management system that allows safe execution of concurrent file operations. My specific focus areas are:
1. **File Copying:** Enabling the safe copying of files using thread management.
2. **File Metadata Display:** Showing file details safely while other operations occur in the background.

## 2. Synchronization and Thread Management Mechanisms

To prevent data corruption, proper synchronization techniques were employed using POSIX Threads (`pthreads`).

### A. Read-Write Locks (`pthread_rwlock_t`)
At the core of the implementation is the **File Manager** (`file_manager.c`), which maintains a registry of files being operated upon. Each file path is assigned a Read-Write Lock.
- **Concurrent Reading:** Multiple threads can simultaneously obtain a `Read Lock` (e.g., executing File Metadata Display) on the same file because reading does not mutate the file.
- **Exclusive Writing:** A thread attempting to copy a file *to* a destination requires a `Write Lock` on that destination file. The system guarantees that only one thread can hold this lock, preventing other threads from modifying or reading the file while it is in an intermediate state.

### B. Mutexes (`pthread_mutex_t`)
- **Global Lock Registry:** Whenever the system searches for or assigns a new file lock in the File Manager, a Mutex prevents thread race conditions from corrupting the internal file registry linked list.
- **Thread-safe Logging:** To prevent terminal output from interleaving randomly when multiple threads print simultaneously, a Mutex in `logger.c` protects the printing buffer. This ensures each log message prints completely on its own line chronologically.

---

## 3. Feature Implementations

### File Metadata Display (`metadata.c`)
- Spawns a dedicated thread that receives a target filename.
- Acquires a **Read Lock** from the File Manager.
- Utilizes the `stat()` POSIX system call to scrape file intelligence.
- Displays:
  - File Size (bytes)
  - Permissions (Octal format)
  - Last Modification and Status Change timestamps
- Safely releases the lock and terminates the thread.

**Code Snapshot (`metadata.c`):**
```c
void* display_metadata_thread(void* arg) {
    const char* path = (const char*)arg;
    struct stat st;

    log_action("Metadata Request", path);

    // Acquire Read Lock to ensure file isn't being deleted/renamed while we read its stats
    acquire_file_lock(path, LOCK_READ);

    if (stat(path, &st) == 0) {
        char details[512];
        snprintf(details, sizeof(details), 
            "\n  Size: %ld bytes\n  Permissions: %o\n  Last Modified: %s  Last Status Change: %s",
            st.st_size, st.st_mode & 0777, ctime(&st.st_mtime), ctime(&st.st_ctime));
        log_action("Metadata Success", details);
    } else {
        char err_msg[256];
        snprintf(err_msg, sizeof(err_msg), "Failed to get metadata for %s: %s", path, strerror(errno));
        log_action("Error", err_msg);
    }

    release_file_lock(path, LOCK_READ);
    return NULL;
}
```


### File Copying (`copy.c`)
- Takes a `source` and `destination` string via thread arguments.
- Safely acquires a **Read Lock** on the source file and an exclusive **Write Lock** on the destination file.
- Copies the file iteratively in binary-safe 4096-byte chunks using `read()` and `write()` calls, bypassing string limitations.
- Logs start, completion, and any potential errors, then safely releases both locks.

**Code Snapshot (`copy.c`):**
```c
void* copy_file_thread(void* arg) {
    copy_args_t* args = (copy_args_t*)arg;
    char log_details[1024];
    snprintf(log_details, sizeof(log_details), "From %s to %s", args->source, args->destination);
    log_action("Copy Started", log_details);

    // Acquire Read Lock for source and Write Lock for destination
    acquire_file_lock(args->source, LOCK_READ);
    acquire_file_lock(args->destination, LOCK_WRITE);

    int src_fd = open(args->source, O_RDONLY);
    if (src_fd < 0) {
        snprintf(log_details, sizeof(log_details), "Failed to open source %s: %s", args->source, strerror(errno));
        log_action("Copy Error", log_details);
        goto cleanup;
    }

    int dst_fd = open(args->destination, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (dst_fd < 0) {
        snprintf(log_details, sizeof(log_details), "Failed to open destination %s: %s", args->destination, strerror(errno));
        log_action("Copy Error", log_details);
        close(src_fd);
        goto cleanup;
    }

    char buffer[4096];
    ssize_t bytes_read, bytes_written;
    while ((bytes_read = read(src_fd, buffer, sizeof(buffer))) > 0) {
        bytes_written = write(dst_fd, buffer, bytes_read);
        if (bytes_written != bytes_read) {
            log_action("Copy Error", "Write mismatch or failure");
            break;
        }
    }

    if (bytes_read < 0) {
        log_action("Copy Error", "Read failure");
    } else {
        log_action("Copy Success", log_details);
    }

    close(src_fd);
    close(dst_fd);

cleanup:
    release_file_lock(args->destination, LOCK_WRITE);
    release_file_lock(args->source, LOCK_READ);
    free(args);
    return NULL;
}
```


---

## 4. Execution Output

When executing the driver code (`main.c`), threads are spawned dynamically to execute copies and read metadata concurrently. The logger displays the timestamp and unique Thread ID of each action.

*(Insert your terminal execution screenshot below)*

**Expected Terminal Trace:**
```text
$ wsl make
$ wsl ./file_manager_sys

[Sun Apr 12 11:02:07 2026] [Thread 127902889277248] System: Multithreaded File Management System Starting...
[Sun Apr 12 11:02:07 2026] [Thread 127902886655680] Metadata Request: test_source.txt
[Sun Apr 12 11:02:07 2026] [Thread 127902869870272] Metadata Request: test_source.txt
[Sun Apr 12 11:02:07 2026] [Thread 127902878262976] Copy Started: From test_source.txt to test_dest1.txt
[Sun Apr 12 11:02:07 2026] [Thread 127902869870272] Metadata Success: 
  Size: 80 bytes
  Permissions: 777
  Last Modified: Sun Apr 12 05:32:07 2026
  Last Status Change: Sun Apr 12 05:32:07 2026

[Sun Apr 12 11:02:07 2026] [Thread 127902886655680] Metadata Success: 
  Size: 80 bytes
  Permissions: 777
  Last Modified: Sun Apr 12 05:32:07 2026
  Last Status Change: Sun Apr 12 05:32:07 2026

[Sun Apr 12 11:02:07 2026] [Thread 127902878262976] Copy Success: From test_source.txt to test_dest1.txt
[Sun Apr 12 11:02:07 2026] [Thread 127902869870272] Copy Started: From test_source.txt to test_dest2.txt
[Sun Apr 12 11:02:07 2026] [Thread 127902869870272] Copy Success: From test_source.txt to test_dest2.txt
[Sun Apr 12 11:02:07 2026] [Thread 127902889277248] System: All operations completed. Shutting down.
```
