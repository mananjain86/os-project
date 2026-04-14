#include "logger.h"
#include <stdio.h>
#include <time.h>
#include <pthread.h>

static pthread_mutex_t log_mutex;

void logger_init() {
    pthread_mutex_init(&log_mutex, NULL);
}

void log_action(const char* action, const char* details) {
    pthread_mutex_lock(&log_mutex);
    
    time_t now;
    time(&now);
    char* date = ctime(&now);
    date[24] = '\0'; // Remove newline

    printf("[%s] [Thread %lu] %s: %s\n", date, (unsigned long)pthread_self(), action, details);
    
    pthread_mutex_unlock(&log_mutex);
}

void logger_destroy() {
    pthread_mutex_destroy(&log_mutex);
}
