﻿#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <time.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#define N 256  // Taille du tableau

// CUDA Kernel pour effectuer la réduction parallèle (réduction interlacée)
__global__ void interleavedReduce(int* input, int n) {
    int tid = threadIdx.x;

    // Réduction parallèle par paires interlacées
    for (int stride = 1; stride < n; stride *= 2) {
        if (tid % (2 * stride) == 0) {
            input[tid] += input[tid + stride];
        }
    }
}

int main() {
    int h_input[N];

    // Initialiser le générateur de nombres aléatoires avec l'horloge système
    srand(time(NULL));

    // Générer des nombres aléatoires entre 1 et 10
    for (int i = 0; i < N; i++) {
        h_input[i] = rand() % 10 + 1;
        printf("Number Added: %d\n", h_input[i]);
    }

    // Allouer la mémoire sur le GPU
    int* d_input;
    cudaMalloc((void**)&d_input, N * sizeof(int));

    // Copier les données de l'hôte (CPU) vers le GPU
    cudaMemcpy(d_input, h_input, N * sizeof(int), cudaMemcpyHostToDevice);

    // Lancer le kernel CUDA avec un bloc de N threads
    interleavedReduce << <1, N >> > (d_input, N);
    cudaDeviceSynchronize();  // Synchroniser les threads avant de passer à la prochaine étape

    // Copier le résultat du GPU vers le CPU
    cudaMemcpy(h_input, d_input, N * sizeof(int), cudaMemcpyDeviceToHost);

    // Afficher le résultat final (la somme des éléments du tableau)
    printf("Final Result (Sum of Table) : %d\n", h_input[0]);

    // Libérer la mémoire sur le GPU
    cudaFree(d_input);

    return 0;
}
