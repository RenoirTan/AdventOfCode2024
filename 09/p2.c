// equivalent C code

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define MAX_LEN (20480) // 0x5000

char DISK_MAP[MAX_LEN] = { 0 };
size_t FSIDX_UP_TO[MAX_LEN] = { 0 };
char BLANK_SPACES[MAX_LEN] = { 0 };
size_t FILE_OFFSETS[MAX_LEN] = { 0 }; // file_id: offset

void convert_disk_map(size_t length) {
    for (int i = 0; i < length; i++) {
        DISK_MAP[i] -= '0';
    }
}

size_t get_filesystem_size(size_t length) {
    size_t sum = 0;
    for (size_t i = 0; i < length; i++) {
        sum += DISK_MAP[i];
    }
    // printf("%llu\n", sum);
    return sum;
}

void setup_file_data(size_t length) {
    size_t fsidx = 0;
    for (size_t i = 0; i < length; i++) {
        if (i % 2 == 0) {
            FILE_OFFSETS[i / 2] = fsidx;
        } else {
            BLANK_SPACES[i] = DISK_MAP[i];
        }
        FSIDX_UP_TO[i] = fsidx;
        fsidx += DISK_MAP[i];
    }
}

uint64_t digest(size_t file_id, size_t offset, size_t length) {
    size_t sum = 0;
    const size_t end = offset + length;
    for (size_t i = offset; i < end; i++) {
        // printf("file_id: %llu, index: %llu\n", file_id, i);
        sum += i;
    }
    return sum * file_id;
}

size_t find_blank_space(size_t limit, size_t length) {
    for (size_t index = 1; index < limit; index += 2) {
        if (BLANK_SPACES[index] >= length) return index;
    }
    return 0;
}

void compact(size_t length) {
    for (size_t bwd_dmidx = length - 1; bwd_dmidx >= 0 && bwd_dmidx < length; bwd_dmidx -= 2) {
        // printf("bwd_dmidx: %llu, DISK_MAP[bwd_dmidx]: %llu\n", bwd_dmidx, DISK_MAP[bwd_dmidx]);
        size_t bsidx = find_blank_space(bwd_dmidx, DISK_MAP[bwd_dmidx]);
        // printf("bsidx: %llu\n", bsidx);
        if (bsidx != 0) {
            size_t bsoffset = DISK_MAP[bsidx] - BLANK_SPACES[bsidx];
            size_t fsidx = FSIDX_UP_TO[bsidx];
            FILE_OFFSETS[bwd_dmidx / 2] = fsidx + bsoffset; // change file offset
            BLANK_SPACES[bsidx] -= DISK_MAP[bwd_dmidx]; // get rid of blank space for file
        }
    }
}

uint64_t calculate_checksum(size_t length) {
    uint64_t cs = 0;
    for (size_t i = 0; i <= (length / 2); i++) {
        cs += digest(i, FILE_OFFSETS[i], DISK_MAP[i*2]);
    }
    return cs;
}

int main(int argc, char **argv) {
    if (argc < 2)  {
        fprintf(stderr, "No file included!\n");
        return 1;
    }
    FILE *infile = fopen(argv[1], "r");
    if (!infile) {
        fprintf(stderr, "Could not open '%s'\n", argv[1]);
        return 1;
    }
    size_t length = MAX_LEN;
    char *_p_to_dm = DISK_MAP;
    if ((length = getline(&_p_to_dm, &length, infile)) == -1) {
        fprintf(stderr, "Could not getline\n");
        return 1;
    }
    // printf("Converting disk map\n");
    convert_disk_map(length);
    // printf("Setting up file data\n");
    setup_file_data(length);
    // printf("Compacting \n");
    compact(length);
    // printf("Calculating\n");
    printf("%llu\n", calculate_checksum(length));
    return 0;
}