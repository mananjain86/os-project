// msgbox_test.c — basic IPC message passing test
// Tests parent-child bidirectional message exchange.

#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  char buf[64];
  int len;

  printf("=== IPC Message Box Test ===\n\n");

  // Parent creates its mailbox
  if(msgbox_create("parent") < 0){
    printf("FAIL: parent could not create mailbox\n");
    exit(1);
  }
  printf("[parent] created mailbox 'parent'\n");

  int pid = fork();
  if(pid < 0){
    printf("FAIL: fork failed\n");
    exit(1);
  }

  if(pid == 0){
    // ---- CHILD ----
    // Create child's own mailbox
    if(msgbox_create("child") < 0){
      printf("FAIL: child could not create mailbox\n");
      exit(1);
    }
    printf("[child]  created mailbox 'child'\n");

    // Send a message to parent
    char *msg1 = "hello from child";
    if(msgbox_send("parent", msg1, strlen(msg1) + 1) < 0){
      printf("FAIL: child could not send to parent\n");
      exit(1);
    }
    printf("[child]  sent: \"%s\"\n", msg1);

    // Small delay so parent prints its receive first
    pause(5);

    // Receive reply from parent
    len = msgbox_recv(buf, sizeof(buf));
    if(len < 0){
      printf("FAIL: child could not receive\n");
      exit(1);
    }
    printf("[child]  received: \"%s\" (%d bytes)\n", buf, len);

    // Check count (should be 0 after receiving)
    int cnt = msgbox_count();
    printf("[child]  pending messages: %d\n", cnt);

    // Cleanup
    msgbox_destroy();
    printf("[child]  destroyed mailbox\n");
    exit(0);

  } else {
    // ---- PARENT ----

    // Receive message from child
    len = msgbox_recv(buf, sizeof(buf));
    if(len < 0){
      printf("FAIL: parent could not receive\n");
      exit(1);
    }
    printf("[parent] received: \"%s\" (%d bytes)\n", buf, len);

    // Send reply to child
    char *msg2 = "hello from parent";
    if(msgbox_send("child", msg2, strlen(msg2) + 1) < 0){
      printf("FAIL: parent could not send to child\n");
      exit(1);
    }
    printf("[parent] sent: \"%s\"\n", msg2);

    // Wait for child to finish
    int status;
    wait(&status);

    // Cleanup
    msgbox_destroy();
    printf("[parent] destroyed mailbox\n");

    printf("\n=== All tests passed! ===\n");
  }

  exit(0);
}
