CC = gcc
CFLAGS = -Wall -pthread
OBJ = main.o logger.o file_manager.o copy.o metadata.o
TARGET = file_manager_sys

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o $(TARGET) test_source.txt test_dest1.txt test_dest2.txt
