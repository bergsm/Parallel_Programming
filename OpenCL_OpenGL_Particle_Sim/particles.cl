typedef float4 point;
typedef float4 vector;
typedef float4 color;
typedef float4 sphere;


vector
Bounce( vector in, vector n )
{
	vector out = in - n*(vector)( 2.*dot(in.xyz, n.xyz) );
	out.w = 0.;
	return out;
}

float4
turnLeft( vector in , float maxVel, float accel)
{
    float4 out = (float4) ( in.x, in.y, in.z, in.w );
	//const float4 G       = (float4) ( 0., -9.8, 0., 0. );
    //printf("In outx: %4.2v4hlf, outz: %4.2v4hlf\n", out.x, out.z);
    //printf("In outx: , outz: \n");
    if (in.x == maxVel && (in.z >= maxVel*-1 && in.z < maxVel))
    {
        out.z+=accel;
        //printf("Out outx: %4.2f, outz: %4.2f\n", out.x, out.z);
        return out;
    }
    if ((in.x > maxVel*-1 && in.x <= maxVel) && in.z == maxVel)
    {
        out.y-=accel;
        //printf("Out outx: %4.2f, outz: %4.2f\n", out.x, out.z);
        return out;
    }
    if ((in.x >= maxVel*-1 && in.x < maxVel) && in.z == maxVel*-1)
    {
        out.y+=accel;
        //printf("Out outx: %4.2f, outz: %4.2f\n", out.x, out.z);
        return out;
    }
    if (in.x == maxVel*-1 && (in.z > maxVel*-1 && in.z <= maxVel))
    {
        out.z-=accel;
        //printf("Out outx: %4.2f, outz: %4.2f\n", out.x, out.z);
        return out;
    }
}


vector
BounceSphere( point p, vector v, sphere s )
{
	vector n;
	n.xyz = fast_normalize( p.xyz - s.xyz );
	n.w = 0.;
	return Bounce( v, n );
}

bool
IsInsideSphere( point p, sphere s )
{
	float r = fast_length( p.xyz - s.xyz );
	return  ( r < s.w );
}

kernel
void
Particle( global point *dPobj, global vector *dVel, global color *dCobj )
{
	const float4 G       = (float4) ( 0., -9.8, 0., 0. );
	const float  DT      = 0.1;
	//const float  maxVel  = 0.03;
	//const float  accel   = 0.01;
	const sphere Sphere1 = (sphere)( -150., -300., 0.,  100. );
	const sphere Sphere2 = (sphere)( 150., -300., 0.,  100. );
	int gid = get_global_id( 0 );

    point p  = dPobj[gid];
    vector v = dVel[gid];
    color c = dCobj[gid];

    point pp  = p + v*DT + G * (point)(.5*DT*DT);
    vector vp = v + G*DT;
    //vector vp = v + G*DT + turnLeft(v, maxVel, accel)*DT;
    pp.w = 1;
    vp.w = 0;

    if( IsInsideSphere( pp, Sphere1) )
    {
        vp = BounceSphere( p, v, Sphere1 );
        pp = p + vp*DT + G * (point)(.5*DT*DT );
        c.g  = 1;
    }
    if( IsInsideSphere( pp, Sphere2) )
    {
        vp = BounceSphere( p, v, Sphere2 );
        pp = p + vp*DT + G * (point)(.5*DT*DT );
        c.r  = 1;
    }

    dPobj[gid] = pp;
    dVel[gid]  = vp;
    dCobj[gid] = c;

}
