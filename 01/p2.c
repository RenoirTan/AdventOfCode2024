#include <stdio.h>
#include <stdlib.h>

#define ARR_LEN (1000)
#define MAX_ID (100000)

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
    // count number of each number
    int n1s[MAX_ID] = { 0 };
    int n2s[MAX_ID] = { 0 };
    int a = 0;
    int b = 0;
    for (int i = 0; fscanf(infile, "%d %d", &a, &b) == 2; i++) {
        n1s[a]++;
        n2s[b]++;
    }
    // get similarity score
    int sum = 0;
    for (int i = 0; i < MAX_ID; i++) {
        sum += i * n1s[i] * n2s[i];
    }
    printf("%d\n", sum);
    return 0;
}