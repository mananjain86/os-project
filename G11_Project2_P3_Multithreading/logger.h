#ifndef LOGGER_H
#define LOGGER_H

#include <pthread.h>

void logger_init();
void log_action(const char* action, const char* details);
void logger_destroy();

#endif
