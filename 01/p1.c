#include <stdio.h>
#include <stdlib.h>

#define ARR_LEN (1000)

int comp(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
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
    int l1[ARR_LEN] = { 0 };
    int l2[ARR_LEN] = { 0 };
    int a = 0;
    int b = 0;
    for (int i = 0; fscanf(infile, "%d %d", &a, &b) == 2; i++) {
        l1[i] = a;
        l2[i] = b;
    }
    qsort(l1, ARR_LEN, sizeof(int), comp);
    qsort(l2, ARR_LEN, sizeof(int), comp);
    int sum = 0;
    for (int i = 0; i < ARR_LEN; i++) {
        sum += abs(l1[i] - l2[i]);
    }
    printf("%d\n", sum);
    return 0;
}