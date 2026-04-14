#include "metadata.h"
#include "file_manager.h"
#include "logger.h"
#include <stdio.h>
#include <sys/stat.h>
#include <time.h>
#include <errno.h>
#include <string.h>

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
