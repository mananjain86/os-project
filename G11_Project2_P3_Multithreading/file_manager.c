#include "file_manager.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct FileLockNode {
    char* path;
    pthread_rwlock_t rwlock;
    struct FileLockNode* next;
} FileLockNode;

static FileLockNode* registry = NULL;
static pthread_mutex_t registry_mutex;

void file_manager_init() {
    pthread_mutex_init(&registry_mutex, NULL);
}

static FileLockNode* find_or_create_lock(const char* path) {
    pthread_mutex_lock(&registry_mutex);
    
    FileLockNode* curr = registry;
    while (curr) {
        if (strcmp(curr->path, path) == 0) {
            pthread_mutex_unlock(&registry_mutex);
            return curr;
        }
        curr = curr->next;
    }

    // Create new node
    FileLockNode* new_node = (FileLockNode*)malloc(sizeof(FileLockNode));
    new_node->path = strdup(path);
    pthread_rwlock_init(&new_node->rwlock, NULL);
    new_node->next = registry;
    registry = new_node;

    pthread_mutex_unlock(&registry_mutex);
    return new_node;
}

void acquire_file_lock(const char* path, lock_type_t type) {
    FileLockNode* node = find_or_create_lock(path);
    if (type == LOCK_READ) {
        pthread_rwlock_rdlock(&node->rwlock);
    } else {
        pthread_rwlock_wrlock(&node->rwlock);
    }
}

void release_file_lock(const char* path, lock_type_t type) {
    pthread_mutex_lock(&registry_mutex);
    FileLockNode* curr = registry;
    while (curr) {
        if (strcmp(curr->path, path) == 0) {
            pthread_rwlock_unlock(&curr->rwlock);
            break;
        }
        curr = curr->next;
    }
    pthread_mutex_unlock(&registry_mutex);
}

void file_manager_destroy() {
    pthread_mutex_lock(&registry_mutex);
    FileLockNode* curr = registry;
    while (curr) {
        FileLockNode* next = curr->next;
        free(curr->path);
        pthread_rwlock_destroy(&curr->rwlock);
        free(curr);
        curr = next;
    }
    registry = NULL;
    pthread_mutex_unlock(&registry_mutex);
    pthread_mutex_destroy(&registry_mutex);
}
