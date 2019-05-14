#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>
#include <stdio.h>
#include "simd.p4.h"

// setting the array size
#ifndef ARRSIZE
#define ARRSIZE   1000000
#endif

// how many tries to discover the maximum performance:
#ifndef NUMTRIES
#define NUMTRIES    25
#endif

float
Ranf( unsigned int *seedp,  float low, float high )
{
        float r = (float) rand_r( seedp );              // 0 - RAND_MAX

        return(   low  +  r * ( high - low ) / (float)RAND_MAX   );
}


void fillArr(float* a, float* b, float* c)
{
    unsigned int seed = time(NULL);
    for (int i=0; i<ARRSIZE; i++)
    {
        a[i] = Ranf(&seed, -10.0, 10.0);
        b[i] = Ranf(&seed, -10.0, 10.0);
        c[i] = 0.0;
    }
}


// main program:
int
main( int argc, char *argv[ ] )
{
#ifndef _OPENMP
    fprintf( stderr, "No OpenMP support!\n" );
    return 1;
#endif

    float* arrA = new float[ARRSIZE];
    float* arrB = new float[ARRSIZE];
    float* arrC = new float[ARRSIZE];


    //SIMD multiplication

    // get ready to record the maximum performance and the volume:
    double maxPerformance = 0.;      // must be declared outside the NUMTRIES loop

    // looking for the maximum performance:
    for( int t = 0; t < NUMTRIES; t++ )
    {
        fillArr(arrA, arrB, arrC);
        double time0 = omp_get_wtime( );

        SimdMul(arrA, arrB, arrC, ARRSIZE);

        double time1 = omp_get_wtime( );
        double megaTrialsPerSecond = (double)(ARRSIZE) / ( time1 - time0 ) / 1000000.;
        if( megaTrialsPerSecond > maxPerformance )
            maxPerformance = megaTrialsPerSecond;
    }
    //print results
    printf("%8.2lf, ",maxPerformance);

    //SIMD multiplaction and reduction
    maxPerformance = 0.;      // must be declared outside the NUMTRIES loop


    // looking for the maximum performance:
    for( int t = 0; t < NUMTRIES; t++ )
    {
        fillArr(arrA, arrB, arrC);
        double time0 = omp_get_wtime( );

        float sum = SimdMulSum(arrA, arrB, ARRSIZE);

        double time1 = omp_get_wtime( );
        double megaTrialsPerSecond = (double)(ARRSIZE) / ( time1 - time0 ) / 1000000.;
        if( megaTrialsPerSecond > maxPerformance )
            maxPerformance = megaTrialsPerSecond;
    }
    //print results
    printf("%8.2lf, ",maxPerformance);

    //Normal multiplaction
    maxPerformance = 0.;      // must be declared outside the NUMTRIES loop

    // looking for the maximum performance:
    for( int t = 0; t < NUMTRIES; t++ )
    {
        fillArr(arrA, arrB, arrC);
        double time0 = omp_get_wtime( );

        NonSimdMul(arrA, arrB, arrC, ARRSIZE);

        double time1 = omp_get_wtime( );
        double megaTrialsPerSecond = (double)(ARRSIZE) / ( time1 - time0 ) / 1000000.;
        if( megaTrialsPerSecond > maxPerformance )
            maxPerformance = megaTrialsPerSecond;
    }
    //print results
    printf("%8.2lf, ",maxPerformance);

    //Normal multiplaction and reduction
    maxPerformance = 0.;      // must be declared outside the NUMTRIES loop

    // looking for the maximum performance:
    for( int t = 0; t < NUMTRIES; t++ )
    {
        fillArr(arrA, arrB, arrC);
        double time0 = omp_get_wtime( );

        float sum = NonSimdMulSum(arrA, arrB, ARRSIZE);

        double time1 = omp_get_wtime( );
        double megaTrialsPerSecond = (double)(ARRSIZE) / ( time1 - time0 ) / 1000000.;
        if( megaTrialsPerSecond > maxPerformance )
            maxPerformance = megaTrialsPerSecond;
    }
    //print results
    printf("%8.2lf",maxPerformance);

    return 0;
}
