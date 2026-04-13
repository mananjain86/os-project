#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>

#define CHUNK_SIZE 4096 // 4 KB chunks for multi-threaded processing

// --- STRUCTURES AND GLOBAL SYNCHRONIZATION ---

typedef struct {
    int thread_id;
    int total_chunks;
    char *input_filename;
    char *output_filename;
} ThreadData;

// Mutex and Condition Variable to enforce ordered, exclusive writing to the compress file
pthread_mutex_t write_mutex;
pthread_cond_t write_cond;
int current_turn = 0;

// --- RLE COMPRESSION/DECOMPRESSION ALGORITHMS ---

/* 
 * Run-Length Encoding (RLE) implementation
 * Returns the size of the compressed data.
 */
int rle_compress(const unsigned char *input, int input_size, unsigned char *output) {
    int out_index = 0;
    int i = 0;
    
    while (i < input_size) {
        unsigned char current_char = input[i];
        unsigned char count = 1;
        
        // Count consecutive matching characters (max 255 for a single byte representation)
        while (i + 1 < input_size && input[i + 1] == current_char && count < 255) {
            count++;
            i++;
        }
        
        output[out_index++] = count;
        output[out_index++] = current_char;
        i++;
    }
    
    return out_index;
}

/* 
 * Run-Length Decoding implementation
 * Returns the size of the uncompressed data.
 */
int rle_decompress(const unsigned char *input, int input_size, unsigned char *output) {
    int out_index = 0;
    for (int i = 0; i < input_size; i += 2) {
        unsigned char count = input[i];
        unsigned char ch = input[i + 1];
        for (int j = 0; j < count; j++) {
            output[out_index++] = ch;
        }
    }
    return out_index;
}

// --- THREAD ROUTINE ---

void* compress_chunk_routine(void* arg) {
    ThreadData *data = (ThreadData*)arg;
    
    // FEATURE 1: Concurrent File Reading
    // Multiple threads are opening and reading from the SAME file simultaneously at different offsets.
    FILE *fin = fopen(data->input_filename, "rb");
    if (!fin) {
        perror("Thread error opening input file");
        pthread_exit(NULL);
    }
    
    long offset = data->thread_id * CHUNK_SIZE;
    fseek(fin, offset, SEEK_SET);
    
    unsigned char *input_buffer = (unsigned char *)malloc(CHUNK_SIZE);
    int bytes_read = fread(input_buffer, 1, CHUNK_SIZE, fin);
    fclose(fin);
    
    if (bytes_read <= 0) {
        free(input_buffer);
        pthread_exit(NULL);
    }
    
    // RLE compression in-memory
    // Max theoretical size for RLE is 2 * input_size (if no characters repeat)
    unsigned char *output_buffer = (unsigned char *)malloc(CHUNK_SIZE * 2);
    int compressed_size = rle_compress(input_buffer, bytes_read, output_buffer);
    
    // FEATURE 2: Exclusive File Writing and Synchronization Mechanisms
    // Ensure that only ONE thread can write to the file at a time, AND in the correct chunk order
    pthread_mutex_lock(&write_mutex);
    
    // Condition variable loop to enforce order
    while (current_turn != data->thread_id) {
        pthread_cond_wait(&write_cond, &write_mutex);
    }
    
    // It's this thread's turn. Open in append mode explicitly
    FILE *fout = fopen(data->output_filename, "ab");
    if (fout) {
        // Write standard chunk metadata: [Original Size] [Compressed Size]
        fwrite(&bytes_read, sizeof(int), 1, fout);
        fwrite(&compressed_size, sizeof(int), 1, fout);
        
        // Write compressed content
        fwrite(output_buffer, 1, compressed_size, fout);
        fclose(fout);
        
        printf("[Log] Thread %d successfully compressed chunk %d. (Size: %d -> %d bytes)\n", 
               data->thread_id, data->thread_id, bytes_read, compressed_size);
    } else {
        perror("Thread error opening output file");
    }
    
    // Signal next thread's turn
    current_turn++;
    pthread_cond_broadcast(&write_cond);
    pthread_mutex_unlock(&write_mutex);
    
    free(input_buffer);
    free(output_buffer);
    pthread_exit(NULL);
}

// --- MAIN FUNCTIONS ---

void compress_file(const char *input_filename, const char *output_filename) {
    FILE *fin = fopen(input_filename, "rb");
    if (!fin) {
        perror("Error opening input file");
        return;
    }
    
    // File Metadata Display
    fseek(fin, 0, SEEK_END);
    long file_size = ftell(fin);
    fclose(fin);
    
    printf("--- Compressing File ---\n");
    printf("Input File: %s\n", input_filename);
    printf("Original File Size: %ld bytes\n", file_size);
    
    if (file_size == 0) {
        printf("File is empty. Nothing to compress.\n");
        return;
    }
    
    // Pre-create/Clear the output file
    FILE *fout = fopen(output_filename, "wb");
    if (fout) fclose(fout);
    
    int total_chunks = (file_size + CHUNK_SIZE - 1) / CHUNK_SIZE;
    printf("Dividing file into %d multithreaded chunks...\n", total_chunks);
    
    pthread_t *threads = (pthread_t*)malloc(total_chunks * sizeof(pthread_t));
    ThreadData *thread_data = (ThreadData*)malloc(total_chunks * sizeof(ThreadData));
    
    // Reset global sync variables
    current_turn = 0;
    pthread_mutex_init(&write_mutex, NULL);
    pthread_cond_init(&write_cond, NULL);
    
    // Create threads
    for (int i = 0; i < total_chunks; i++) {
        thread_data[i].thread_id = i;
        thread_data[i].total_chunks = total_chunks;
        thread_data[i].input_filename = (char*)input_filename;
        thread_data[i].output_filename = (char*)output_filename;
        
        if (pthread_create(&threads[i], NULL, compress_chunk_routine, &thread_data[i]) != 0) {
            perror("Failed to create thread");
        }
    }
    
    // Join threads
    for (int i = 0; i < total_chunks; i++) {
        pthread_join(threads[i], NULL);
    }
    
    free(threads);
    free(thread_data);
    
    fout = fopen(output_filename, "rb");
    if (fout) {
        fseek(fout, 0, SEEK_END);
        long new_size = ftell(fout);
        fclose(fout);
        printf("--- Compression Complete ---\n");
        printf("Final Compressed file size: %ld bytes\n", new_size);
    }
}

void decompress_file(const char *input_filename, const char *output_filename) {
    FILE *fin = fopen(input_filename, "rb");
    if (!fin) {
        perror("Error opening compressed file");
        return;
    }
    
    FILE *fout = fopen(output_filename, "wb");
    if (!fout) {
        perror("Error creating decompressed file");
        fclose(fin);
        return;
    }
    
    printf("--- Decompressing File ---\n");
    
    int block_index = 0;
    while (!feof(fin)) {
        int original_size, compressed_size;
        
        // Read header metadata
        if (fread(&original_size, sizeof(int), 1, fin) != 1) break;
        if (fread(&compressed_size, sizeof(int), 1, fin) != 1) break;
        
        unsigned char *comp_buffer = (unsigned char*)malloc(compressed_size);
        unsigned char *uncomp_buffer = (unsigned char*)malloc(original_size);
        
        if (fread(comp_buffer, 1, compressed_size, fin) != compressed_size) {
            printf("Error reading block %d!\n", block_index);
            free(comp_buffer);
            free(uncomp_buffer);
            break;
        }
        
        // Decompress
        int out_size = rle_decompress(comp_buffer, compressed_size, uncomp_buffer);
        
        // Write to output file
        fwrite(uncomp_buffer, 1, out_size, fout);
        
        printf("[Log] Decompressed chunk %d. (Reduced from %d -> %d bytes)\n", 
               block_index++, compressed_size, out_size);
               
        free(comp_buffer);
        free(uncomp_buffer);
    }
    
    fclose(fin);
    fclose(fout);
    printf("--- Decompression Complete ---\n");
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage:\n");
        printf("  %s -c <input_file> <compressed_file>\n", argv[0]);
        printf("  %s -d <compressed_file> <output_file>\n", argv[0]);
        return 1;
    }
    
    if (strcmp(argv[1], "-c") == 0) {
        compress_file(argv[2], argv[3]);
    } else if (strcmp(argv[1], "-d") == 0) {
        decompress_file(argv[2], argv[3]);
    } else {
        printf("Invalid mode! Use -c for compression or -d for decompression.\n");
        return 1;
    }
    
    return 0;
}
