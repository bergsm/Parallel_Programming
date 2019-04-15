#include <stdio.h>
#include <omp.h>

#ifndef _OPENMP
    fprintf(stderr, "OpenMP is not supported -- sorry!\n");
    exit(0);
#endif

int main()
{
    omp_set_num_threads(8);
    #pragma omp parallel default(none)
    {
        printf("Hello, World, from thread #%d!\n", omp_get_thread_num());
    }
    return 0;
}

