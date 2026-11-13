#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifndef N
#define N 1200
#endif

#if defined(__GNUC__) || defined(__clang__)
#define NOINLINE __attribute__((noinline))
#define RESTRICT __restrict__
#else
#define NOINLINE
#define RESTRICT __restrict
#endif

NOINLINE void mult_ijk(int n, double * RESTRICT A, double * RESTRICT B, double * RESTRICT C) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            double sum = 0.0;
            for (int k = 0; k < n; ++k) {
                sum += A[i * n + k] * B[k * n + j];
            }
            C[i * n + j] = sum;
        }
    }
}

NOINLINE void mult_ikj(int n, double * RESTRICT A, double * RESTRICT B, double * RESTRICT C) {
    for (int i = 0; i < n; ++i) {
        for (int k = 0; k < n; ++k) {
            double r = A[i * n + k];
            for (int j = 0; j < n; ++j) {
                C[i * n + j] += r * B[k * n + j];
            }
        }
    }
}

NOINLINE void init_matrices(int n, double *A, double *B, double *C) {
    for (int i = 0; i < n * n; ++i) {
        A[i] = (double)(i % 100) * 0.01;
        B[i] = (double)((i + 17) % 100) * 0.02;
        C[i] = 0.0;
    }
}

int main(int argc, char **argv) {
    int n = (argc > 1) ? atoi(argv[1]) : N;
    int repeats = (argc > 2) ? atoi(argv[2]) : 1;

    size_t bytes = (size_t)n * n * sizeof(double);
    double *A = (double *)malloc(bytes);
    double *B = (double *)malloc(bytes);
    double *C = (double *)malloc(bytes);

    if (!A || !B || !C) {
        return 1;
    }

    init_matrices(n, A, B, C);

    clock_t start = clock();

    for (int r = 0; r < repeats; ++r) {
#ifdef USE_OPT_IKJ
        mult_ikj(n, A, B, C);
#else
        mult_ijk(n, A, B, C);
#endif
    }

    clock_t end = clock();
    double elapsed = (double)(end - start) / CLOCKS_PER_SEC;

    double checksum = 0.0;
    for (int i = 0; i < n * n; i += n + 1) {
        checksum += C[i];
    }

    printf("N=%d repeats=%d checksum=%.4f time=%.4fs\n", n, repeats, checksum, elapsed);

    free(A);
    free(B);
    free(C);
    return 0;
}