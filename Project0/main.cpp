#include <omp.h>
#include <stdio.h>
#include <math.h>
#include <float.h>

#ifndef NUMT
#define NUMT             4
#endif
#define ARRAYSIZE       100000  // you decide
#define NUMTRIES        100000  // you decide

float A[ARRAYSIZE];
float B[ARRAYSIZE];
float C[ARRAYSIZE];

int
main( )
{
#ifndef _OPENMP
        fprintf( stderr, "OpenMP is not supported here -- sorry.\n" );
        return 1;
#endif
        int numprocs = omp_get_num_procs();
        printf("Number of processors: %d\n", numprocs);
        printf("Arraysize: %d\n", ARRAYSIZE);
        printf("Tries: %d\n", NUMTRIES);

        omp_set_num_threads( NUMT );
        fprintf( stderr, "Using %d threads\n", NUMT );

        double maxMegaMults = 0.;
        double minPeakTime = DBL_MAX;

        for( int t = 0; t < NUMTRIES; t++ )
        {
                double time0 = omp_get_wtime( );

                #pragma omp parallel for
                for( int i = 0; i < ARRAYSIZE; i++ )
                {
                        C[i] = A[i] * B[i];
                }

                double time1 = omp_get_wtime( );
                double megaMults = (double)ARRAYSIZE/(time1-time0)/1000000.;
                // get time in microseconds
                double peakTime = (time1-time0) * 1000;
                //printf( "Peak Time = %8.4lf microseconds\n", peakTime );
                //printf( "Time 1 = %8.4lf Sec\n", time1 );
                //printf( "Time 2 = %8.4lf Sec\n", time0 );
                if( megaMults > maxMegaMults )
                        maxMegaMults = megaMults;
                if( peakTime < minPeakTime )
                        minPeakTime = peakTime;
        }

        printf( "Peak Performance = %8.2lf MegaMults/Sec\n", maxMegaMults );
        printf( "Peak Time = %8.4lf microseconds\n", minPeakTime );

    // note: %lf stands for "long float", which is how printf prints a "double"
    //        %d stands for "decimal integer", not "double"

        return 0;
}
