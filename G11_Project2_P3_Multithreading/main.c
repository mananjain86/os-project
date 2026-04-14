#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include "logger.h"
#include "file_manager.h"
#include "copy.h"
#include "metadata.h"

void create_test_file(const char* filename, const char* content) {
    FILE* f = fopen(filename, "w");
    if (f) {
        fprintf(f, "%s", content);
        fclose(f);
    }
}

int main() {
    logger_init();
    file_manager_init();

    log_action("System", "Multithreaded File Management System Starting...");

    // Create a test file
    create_test_file("test_source.txt", "This is a test file for multithreaded copying and metadata display.\nHello World!");

    pthread_t thread1, thread2, thread3;

    // 1. Thread for Metadata Display
    pthread_create(&thread1, NULL, display_metadata_thread, (void*)"test_source.txt");

    // 2. Thread for File Copying
    copy_args_t* args1 = (copy_args_t*)malloc(sizeof(copy_args_t));
    strcpy(args1->source, "test_source.txt");
    strcpy(args1->destination, "test_dest1.txt");
    pthread_create(&thread2, NULL, copy_file_thread, args1);

    // 3. Another Thread for Metadata (concurrent read)
    pthread_create(&thread3, NULL, display_metadata_thread, (void*)"test_source.txt");

    // Wait for threads to finish
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    pthread_join(thread3, NULL);

    // One more copy to show concurrency
    copy_args_t* args2 = (copy_args_t*)malloc(sizeof(copy_args_t));
    strcpy(args2->source, "test_source.txt");
    strcpy(args2->destination, "test_dest2.txt");
    pthread_create(&thread1, NULL, copy_file_thread, args2);
    pthread_join(thread1, NULL);

    log_action("System", "All operations completed. Shutting down.");

    file_manager_destroy();
    logger_destroy();

    return 0;
}
