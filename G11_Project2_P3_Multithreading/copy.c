#include "copy.h"
#include "file_manager.h"
#include "logger.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

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
