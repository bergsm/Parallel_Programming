// Array multiplication: C = A * B:

// System includes
#include <stdio.h>
#include <assert.h>
#include <malloc.h>
#include <math.h>
#include <stdlib.h>

// CUDA runtime
#include <cuda_runtime.h>

// Helper functions and utilities to work with CUDA
#include "helper_functions.h"
#include "helper_cuda.h"

// for printing probability
#ifndef LAST
#define LAST        0
#endif

#ifndef BLOCKSIZE
#define BLOCKSIZE		32		// number of threads per block
#endif

#ifndef SIZE
#define SIZE			1*1024*1024	// array size
#endif

#ifndef NUMTRIES
#define NUMTRIES		100		// to make the timing more accurate
#endif

#ifndef TOLERANCE
#define TOLERANCE		0.00001f	// tolerance to relative error
#endif

// ranges for the random numbers:
const float XCMIN =  0.0;
const float XCMAX =  2.0;
const float YCMIN =  0.0;
const float YCMAX =  2.0;
const float RMIN  =  0.5;
const float RMAX  =  2.0;

// function prototypes:
float       Ranf( float, float );
int     Ranf( int, int );
void        TimeOfDaySeed( );


// array multiplication (CUDA Kernel) on the device: C = A * B

__global__  void MonteCarlo( float *xcs, float *ycs, float *rs , int *hits)
{
	//__shared__ float prods[BLOCKSIZE];

	//unsigned int numItems = blockDim.x;
	//unsigned int tnum = threadIdx.x;
	//unsigned int wgNum = blockIdx.x;
	unsigned int gid = blockIdx.x*blockDim.x + threadIdx.x;

    // grab location and radius of circle
    float xc = xcs[gid];
    float yc = ycs[gid];
    float r  = rs[gid];

    // solve for the intersection using the quadratic formula:
    float a = 2.;
    float b = -2.*( xc + yc );
    float c = xc*xc + yc*yc - r*r;
    float d = b*b - 4.*a*c;

    //If d is less than 0., then the circle completely missed. (Case A) Continue on to the next trail in the for-loop.
    if (d > 0)
    {
        // hits the circle:
        // get the first intersection:
        d = sqrt( d );
        float t1 = (-b + d ) / ( 2.*a );    // time to intersect the circle
        float t2 = (-b - d ) / ( 2.*a );    // time to intersect the circle
        float tmin = t1 < t2 ? t1 : t2;     // only care about the first intersection
        //If tmin is less than 0., then the circle completely engulfs the laser pointer. (Case B) Continue on to the next trial in the for-loop.
        if (tmin > 0)
        {

            // where does it intersect the circle?
            float xcir = tmin;
            float ycir = tmin;

            // get the unitized normal vector at the point of intersection:
            float nx = xcir - xc;
            float ny = ycir - yc;
            float n = sqrt( nx*nx + ny*ny );
            nx /= n;    // unit vector
            ny /= n;    // unit vector

            // get the unitized incoming vector:
            float inx = xcir - 0.;
            float iny = ycir - 0.;
            float in = sqrt( inx*inx + iny*iny );
            inx /= in;  // unit vector
            iny /= in;  // unit vector

            // get the outgoing (bounced) vector:
            float dot = inx*nx + iny*ny;
            float outx = inx - 2.*nx*dot;   // angle of reflection = angle of incidence`
            float outy = iny - 2.*ny*dot;   // angle of reflection = angle of incidence`

            // find out if it hits the infinite plate:
            float t = ( 0. - ycir ) / outy;
            //If t is less than 0., then the reflected beam went up instead of down. Continue on to the next trial in the for-loop.
            if (t > 0)
            {

        //Otherwise, this beam hit the infinite plate. (Case D) Increment the number of hits and continue on to the next trial in the for-loop.
                hits[gid] = 1;
            }
        }
    }



	//prods[tnum] = A[gid] * B[gid];

	//for (int offset = 1; offset < numItems; offset *= 2)
	//{
	//	int mask = 2 * offset - 1;
	//	__syncthreads();
	//	if ((tnum & mask) == 0)
	//	{
	//		prods[tnum] += prods[tnum + offset];
	//	}
	//}

	//__syncthreads();
	//if (tnum == 0)
	//	C[wgNum] = prods[0];
}


// main program:

int
main( int argc, char* argv[ ] )
{
    // print relevant information to screen
    fprintf(stderr, "Blocksize: %d\tArray size: %d\tTries: %d\n", BLOCKSIZE, SIZE, NUMTRIES);

    TimeOfDaySeed( );       // seed the random number generator

    // uncomment to print device information
	//int dev = findCudaDevice(argc, (const char **)argv);

	// allocate host memory:
    // better to define these here so that the rand() calls don't get into the thread timing:
    float *hxcs = new float [SIZE];
    float *hycs = new float [SIZE];
    float * hrs = new float [SIZE];
    int   *hits = new int [SIZE];

    // fill the random-value arrays:
    for( int n = 0; n < SIZE; n++ )
    {
            hxcs[n] = Ranf( XCMIN, XCMAX );
            hycs[n] = Ranf( YCMIN, YCMAX );
            hrs[n] = Ranf(  RMIN,  RMAX );
            hits[n] = 0;
    }

	//float * hA = new float [ SIZE ];
	//float * hB = new float [ SIZE ];
	//float * hC = new float [ SIZE/BLOCKSIZE ];

	//for( int i = 0; i < SIZE; i++ )
	//{
	//	hA[i] = hB[i] = (float) sqrt(  (float)(i+1)  );
	//}

	// allocate device memory:

	float *dA, *dB, *dC;
	int *dD;

	dim3 dimsA( SIZE, 1, 1 );
	dim3 dimsB( SIZE, 1, 1 );
	dim3 dimsC( SIZE, 1, 1 );
	dim3 dimsD( SIZE, 1, 1 );
//	dim3 dimsC( SIZE/BLOCKSIZE, 1, 1 );

	//__shared__ float prods[SIZE/BLOCKSIZE];


	cudaError_t status;
	status = cudaMalloc( reinterpret_cast<void **>(&dA), SIZE*sizeof(float) );
		checkCudaErrors( status );
	status = cudaMalloc( reinterpret_cast<void **>(&dB), SIZE*sizeof(float) );
		checkCudaErrors( status );
	status = cudaMalloc( reinterpret_cast<void **>(&dC), SIZE*sizeof(float) );
		checkCudaErrors( status );
	status = cudaMalloc( reinterpret_cast<void **>(&dD), SIZE*sizeof(int) );
		checkCudaErrors( status );
	//status = cudaMalloc( reinterpret_cast<void **>(&dC), (SIZE/BLOCKSIZE)*sizeof(float) );
		//checkCudaErrors( status );


	// copy host memory to the device:

	status = cudaMemcpy( dA, hxcs, SIZE*sizeof(float), cudaMemcpyHostToDevice );
		checkCudaErrors( status );
	status = cudaMemcpy( dB, hycs, SIZE*sizeof(float), cudaMemcpyHostToDevice );
		checkCudaErrors( status );
	status = cudaMemcpy( dC, hrs, SIZE*sizeof(float), cudaMemcpyHostToDevice );
		checkCudaErrors( status );
	status = cudaMemcpy( dD, hits, SIZE*sizeof(int), cudaMemcpyHostToDevice );
		checkCudaErrors( status );

	// setup the execution parameters:

	dim3 threads(BLOCKSIZE, 1, 1 );
	dim3 grid( SIZE / threads.x, 1, 1 );

	// Create and start timer

	cudaDeviceSynchronize( );

	// allocate CUDA events that we'll use for timing:

	cudaEvent_t start, stop;
	status = cudaEventCreate( &start );
		checkCudaErrors( status );
	status = cudaEventCreate( &stop );
		checkCudaErrors( status );

	// record the start event:

	status = cudaEventRecord( start, NULL );
		checkCudaErrors( status );

	// execute the kernel:

	for( int t = 0; t < NUMTRIES; t++)
	{
	        MonteCarlo<<< grid, threads >>>( dA, dB, dC, dD );
	}

	// record the stop event:

	status = cudaEventRecord( stop, NULL );
		checkCudaErrors( status );

	// wait for the stop event to complete:

	status = cudaEventSynchronize( stop );
		checkCudaErrors( status );

	float msecTotal = 0.0f;
	status = cudaEventElapsedTime( &msecTotal, start, stop );
		checkCudaErrors( status );

	// compute and print the performance

	double secondsTotal = 0.001 * (double)msecTotal;
	double multsPerSecond = (float)SIZE * (float)NUMTRIES / secondsTotal;
	double megaMultsPerSecond = multsPerSecond / 1000000.;
	fprintf( stderr, "Array Size = %10d, MegaTrials/Second = %10.2lf\n", SIZE, megaMultsPerSecond );
	printf("%10.2lf,", megaMultsPerSecond );

	// copy result from the device to the host:
	status = cudaMemcpy( hits, dD, SIZE*sizeof(float), cudaMemcpyDeviceToHost );
		checkCudaErrors( status );

    // deduce probability from hits array
    int totalHits = 0;
	float prob = 0.;
	for(int i = 0; i < SIZE; i++ )
	{
		totalHits += hits[i];
	}
    prob = (float)totalHits/SIZE;
	fprintf( stderr, "\nprobability = %4.4lf\n", prob );

    //print results
    if (LAST)
    {
        FILE* fp;
        fp = fopen("prob.txt", "w+");
        fprintf(fp, "%4.4lf", prob);
        fclose(fp);
    }

	// clean up memory:
	delete [ ] hxcs;
	delete [ ] hycs;
	delete [ ] hrs;
	delete [ ] hits;

	status = cudaFree( dA );
		checkCudaErrors( status );
	status = cudaFree( dB );
		checkCudaErrors( status );
	status = cudaFree( dC );
		checkCudaErrors( status );
	status = cudaFree( dD );
		checkCudaErrors( status );


	return 0;
}

float Ranf( float low, float high )
{
        float r = (float) rand();               // 0 - RAND_MAX
        float t = r  /  (float) RAND_MAX;       // 0. - 1.

        return   low  +  t * ( high - low );
}

int Ranf( int ilow, int ihigh )
{
        float low = (float)ilow;
        float high = ceil( (float)ihigh );

        return (int) Ranf(low,high);
}

void TimeOfDaySeed( )
{
    struct tm y2k = { 0 };
    y2k.tm_hour = 0;   y2k.tm_min = 0; y2k.tm_sec = 0;
    y2k.tm_year = 100; y2k.tm_mon = 0; y2k.tm_mday = 1;

    time_t  timer;
    time( &timer );
    double seconds = difftime( timer, mktime(&y2k) );
    unsigned int seed = (unsigned int)( 1000.*seconds );    // milliseconds
    srand( seed );
}


