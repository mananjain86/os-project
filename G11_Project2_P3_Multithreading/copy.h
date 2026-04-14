#ifndef COPY_H
#define COPY_H

typedef struct {
    char source[256];
    char destination[256];
} copy_args_t;

void* copy_file_thread(void* arg);

#endif
