// equivalent C code

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define MAX_LEN (20480) // 0x5000

char DISK_MAP[MAX_LEN] = { 0 };

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

size_t get_num_of_used_space(size_t length) {
    size_t sum = 0;
    for (size_t i = 0; i < length; i += 2) {
        sum += DISK_MAP[i];
    }
    return sum;
}

size_t get_index_of_partition(size_t used_space, size_t length) {
    size_t sum = 0;
    for (size_t i = 0; i < length; i++) {
        sum += DISK_MAP[i];
        if (sum >= length) {
            return i;
        }
    }
    return 0;
}

uint64_t calculate_checksum(size_t length) {
    size_t fwd_dmidx = 0; // diskmap index
    size_t bwd_dmidx = length - 1; // assume that length is odd, i.e. last block is a file
    size_t fwd_rmbyt = DISK_MAP[fwd_dmidx]; // remaining bytes for this block
    size_t bwd_rmbyt = DISK_MAP[bwd_dmidx];
    size_t fwd_fsidx = 0; // filesystem index
    size_t bwd_fsidx = get_filesystem_size(length) - 1;
    uint64_t checksum = 0;
    while (fwd_fsidx <= bwd_fsidx) {
        if (fwd_rmbyt <= 0) {
            fwd_dmidx++;
            fwd_rmbyt = DISK_MAP[fwd_dmidx];
            continue;
        }
        if (bwd_rmbyt <= 0) {
            bwd_dmidx -= 2; // ignore empty blocks
            bwd_rmbyt = DISK_MAP[bwd_dmidx];
            bwd_fsidx -= DISK_MAP[bwd_dmidx+1]; // account for skipped empty block
            continue;
        }
        if (fwd_dmidx % 2 == 0) { // currently on a file block
            checksum += fwd_fsidx * (fwd_dmidx / 2);
            fwd_rmbyt--;
            fwd_fsidx++;
        } else {
            checksum += fwd_fsidx * (bwd_dmidx / 2);
            bwd_rmbyt--;
            bwd_fsidx--;
            fwd_rmbyt--;
            fwd_fsidx++;
        }
    }
    return checksum;
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
    convert_disk_map(length);
    printf("%llu\n", calculate_checksum(length));
    return 0;
}