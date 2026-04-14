#ifndef FILE_MANAGER_H
#define FILE_MANAGER_H

#include <pthread.h>

typedef enum {
    LOCK_READ,
    LOCK_WRITE
} lock_type_t;

void file_manager_init();
void file_manager_destroy();

// Acquires a lock for a specific file path.
// If the lock doesn't exist in the registry, it is created.
void acquire_file_lock(const char* path, lock_type_t type);

// Releases the lock for a specific file path.
void release_file_lock(const char* path, lock_type_t type);

#endif
