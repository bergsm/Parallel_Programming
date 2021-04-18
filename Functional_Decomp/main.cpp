#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>
#include <stdio.h>

//Globals
int NowYear;        // 2019 - 2024
int NowMonth;       // 0 - 11
int totalMonths;

float   NowPrecip;      // inches of rain per month
float   NowTemp;        // temperature this month
float   NowHeight;      // grain height in inches
int NowNumDeer;     // number of deer in the current population
float NowFertilizer; // Amount of fertilizer from deer in the soil

// constant values
const int YEAR_END = 2100;
const float GRAIN_GROWS_PER_MONTH =     8.0;
const float ONE_DEER_EATS_PER_MONTH =   0.5;

const float AVG_PRECIP_PER_MONTH =      6.0;    // average
const float AMP_PRECIP_PER_MONTH =      6.0;    // plus or minus
const float RANDOM_PRECIP =             2.0;    // plus or minus noise

const float AVG_TEMP =              50.0;   // average
const float AMP_TEMP =              20.0;   // plus or minus
const float RANDOM_TEMP =           10.0;   // plus or minus noise

const float MIDTEMP =               40.0;
const float MIDPRECIP =             10.0;


//random float generators
float
Ranf( unsigned int *seedp,  float low, float high )
{
        float r = (float) rand_r( seedp );              // 0 - RAND_MAX

        return(   low  +  r * ( high - low ) / (float)RAND_MAX   );
}


int
Ranf( unsigned int *seedp, int ilow, int ihigh )
{
        float low = (float)ilow;
        float high = (float)ihigh + 0.9999f;

        return (int)(  Ranf(seedp, low,high) );
}

float
SQR( float x)
{
    return x*x;
}



void Weather(unsigned int seed)
{
        float tempFactor = exp ( -SQR( ( NowTemp - MIDTEMP ) / 10. ) );
        float precipFactor = exp( -SQR( ( NowPrecip - MIDPRECIP ) / 10. ) );

        float ang = (  30.*(float)NowMonth + 15.  ) * ( M_PI / 180. );

        float temp = AVG_TEMP - AMP_TEMP * cos( ang );
        NowTemp = temp + Ranf( &seed, -RANDOM_TEMP, RANDOM_TEMP );

        float precip = AVG_PRECIP_PER_MONTH + AMP_PRECIP_PER_MONTH * sin( ang );
        NowPrecip = precip + Ranf( &seed,  -RANDOM_PRECIP, RANDOM_PRECIP );
        if( NowPrecip < 0. )
            NowPrecip = 0.;
}

// simulation functions
void GrainDeer()
{
    while (NowYear < YEAR_END)
    {
        int NextNumDeer;
        // compute a temporary next-value for this quantity
        // based on the current state of the simulation:
        if (NowNumDeer > NowHeight || (NowFertilizer > NowNumDeer && NowNumDeer > 0))
            NextNumDeer = NowNumDeer - 1;
        else if (NowNumDeer < NowHeight)
            NextNumDeer = NowNumDeer + 1;
        else
            NextNumDeer = NowNumDeer;
        // DoneComputing barrier:
        #pragma omp barrier

        //Assign temp variable to global variable
        NowNumDeer = NextNumDeer;
        if (NowNumDeer < 0)
            NowNumDeer = 0;
        // DoneAssigning barrier:
        #pragma omp barrier

        // Wait for watcher to update and print data

        // DonePrinting barrier:
        #pragma omp barrier
    }
}


void Grain()
{
    while (NowYear < YEAR_END)
    {
        float tempFactor = exp ( -SQR( ( NowTemp - MIDTEMP ) / 10. ) );
        float precipFactor = exp( -SQR( ( NowPrecip - MIDPRECIP ) / 10. ) );
        float NextHeight = 0.;
        // compute a temporary next-value for this quantity
        // based on the current state of the simulation:
        NextHeight += tempFactor * precipFactor * GRAIN_GROWS_PER_MONTH;
        NextHeight += .05 * NowFertilizer * GRAIN_GROWS_PER_MONTH;
        NextHeight -= (float)NowNumDeer * ONE_DEER_EATS_PER_MONTH;


        // DoneComputing barrier:
        #pragma omp barrier
        NowHeight += NextHeight;
        if (NowHeight < 0)
            NowHeight = 0.;

        // DoneAssigning barrier:
        #pragma omp barrier

        // Wait for watcher to update and print data

        // DonePrinting barrier:
        #pragma omp barrier
    }
}

void MyAgent()
{
    while (NowYear < YEAR_END)
    {
        // compute a temporary next-value for this quantity
        // based on the current state of the simulation:
        float NextFertilizer = .4 * NowNumDeer - .2 * NowHeight;

        // DoneComputing barrier:
        #pragma omp barrier
        NowFertilizer += NextFertilizer;
        if (NowFertilizer < 0)
            NowFertilizer = 0.;

        // DoneAssigning barrier:
        #pragma omp barrier

        // Wait for watcher function

        // DonePrinting barrier:
        #pragma omp barrier
    }
}


void Watcher(unsigned int seed)
{
    while (NowYear < YEAR_END)
    {
        // compute a temporary next-value for this quantity
        // based on the current state of the simulation:

        // Wait for values to calculate

        // DoneComputing barrier:
        #pragma omp barrier

        // Wait for values to assign

        // DoneAssigning barrier:
        #pragma omp barrier

        //Print results

        totalMonths++;
    printf("%d,%6.4lf,%6.4lf,%6.4lf,%d,%6.4lf\n", totalMonths, (5./9.)*(NowTemp-32), NowPrecip*2.54, NowHeight*2.54, NowNumDeer, NowFertilizer);
        //Uncomment for US units
        //printf("%d,%6.4lf,%6.4lf,%6.4lf,%d,%6.4lf\n", totalMonths, NowTemp, NowPrecip, NowHeight, NowNumDeer, NowFertilizer);

        NowMonth++;
        if(NowMonth > 11)
        {
            NowYear++;
            NowMonth = 0;
        }

        //Calculate current environment parameters
        Weather(seed);
        // DonePrinting barrier:
        #pragma omp barrier
    }
}


// main program:
int
main( int argc, char *argv[ ] )
{
    unsigned int seed = time(NULL);  // a thread-private variable
    #ifndef _OPENMP
    fprintf( stderr, "No OpenMP support!\n" );
    return 1;
    #endif

    omp_set_num_threads( 4 );    // set the number of threads to use for sections

    //Calculate current environment parameters
    Weather(seed);

    // starting date and time:
    NowMonth =    0;
    totalMonths =    0;
    NowYear  = 2019;

    // starting state (feel free to change this if you want):
    NowNumDeer = 1;
    NowHeight =  1.;
    NowFertilizer = 0.;

    printf("Month, Temp, Precip, Height, Deer Pop, Fertilizer\n");
    // Uncomment for US units
    //printf("%d,%6.4lf,%6.4lf,%6.4lf,%d,%6.4lf\n", totalMonths, NowTemp, NowPrecip, NowHeight, NowNumDeer, NowFertilizer);
    printf("%d,%6.4lf,%6.4lf,%6.4lf,%d,%6.4lf\n", totalMonths, (5./9.)*(NowTemp-32), NowPrecip*2.54, NowHeight*2.54, NowNumDeer, NowFertilizer);

    #pragma omp parallel sections
    {
        #pragma omp section
        {
            GrainDeer( );
        }

        #pragma omp section
        {
            Grain( );
        }

        #pragma omp section
        {
            Watcher(seed);
        }

        #pragma omp section
        {
            MyAgent( ); // your own
        }
    }       // implied barrier -- all functions must return in order
        // to allow any of them to get past here


   return 0;
}
