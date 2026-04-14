CC = gcc
CFLAGS = -Wall -pthread -g

# Targets
TARGET_SYS = file_manager_sys
TARGET_F3F4 = file_manager_f3f4

# Objects for TARGET_SYS
OBJ_SYS = main.o logger.o file_manager.o copy.o metadata.o

# Source for TARGET_F3F4
SRC_F3F4 = file_manager_f3f4.c

.PHONY: all clean run

all: $(TARGET_SYS) $(TARGET_F3F4)

$(TARGET_SYS): $(OBJ_SYS)
	$(CC) $(CFLAGS) -o $@ $^

$(TARGET_F3F4): $(SRC_F3F4)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET_F3F4)
	./$(TARGET_F3F4)

clean:
	rm -f *.o $(TARGET_SYS) $(TARGET_F3F4) file_operations.log
	rm -f test_source.txt test_dest1.txt test_dest2.txt
	rm -f demo_delete*.txt demo_rename*.txt demo_renamed*.txt
