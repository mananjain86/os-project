#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  printf("Starting Shared Memory Test...\n");

  // Create or get a shared memory segment
  int shmid = shmcreate(1234);
  if (shmid < 0) {
    printf("shmcreate failed\n");
    exit(1);
  }

  int pid = fork();
  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    // Child Process
    char *shm_ptr = (char*)shmat(shmid);
    if ((uint64)shm_ptr == (uint64)-1) {
      printf("child shmat failed\n");
      exit(1);
    }
    printf("Child: Writing to shared memory...\n");
    strcpy(shm_ptr, "Hello from child process via SHM!");
    
    // Detach and exit
    shmdt(shmid);
    exit(0);
  } else {
    // Parent Process
    wait(0); // Wait for child to finish writing

    char *shm_ptr = (char*)shmat(shmid);
    if ((uint64)shm_ptr == (uint64)-1) {
      printf("parent shmat failed\n");
      exit(1);
    }
    
    printf("Parent: Read from shared memory: '%s'\n", shm_ptr);
    
    // Detach
    shmdt(shmid);
  }

  printf("Shared Memory Test completed successfully.\n");
  exit(0);
}
