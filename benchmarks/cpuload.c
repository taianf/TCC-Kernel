#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <pthread.h>
#include <errno.h>

static void *start_routine(void *arg) {
    while (true) {}
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s NR_THREADS", argv[0]);
        exit(EXIT_FAILURE);
    }

    int nr_threads = atoi(argv[1]);
    if (nr_threads < 1) {
        fprintf(stderr, "NR_THREADS should be >= 1, %d is not.\n", nr_threads);
        exit(EXIT_FAILURE);
    }

    pthread_t ids[nr_threads];
    for (int i = 0; i < nr_threads; i++) {
        errno = pthread_create(&ids[i], NULL, start_routine, NULL);
        if (errno) {
            perror("pthread_create");
            exit(EXIT_FAILURE);
        }
    }
    for (int i = 0; i < nr_threads; i++) {
        errno = pthread_join(ids[i], NULL);
        if (errno) {
            perror("pthread_join");
            exit(EXIT_FAILURE);
        }
    }

    exit(EXIT_SUCCESS);
}

