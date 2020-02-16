
#include <stdio.h>
/*
	Box. Augments old versions with a cylinder model that has a finite length.
	Old Box changed to infBox to better reflect its model. Based on infBox
	but with length parameter.
	Added: July 18, 2016
	Author: Michael Honke (based on original Box, now infBox, by Trevor Vincent).
	*/
#include "Box.cuh"

__global__ void Box_GPU(Box** obj_ptr, Vector3 _center, real _l_half,real _w_half, real _d_half, real _T2, real _T1, real _D, int _region, real _permeability, int num_particles, real _eps);

__device__ __host__ Box::Box(Vector3 _center, real _l_half,real _w_half, real _d_half, real _T2, real _T1, real _D, int _region, real _permeability, int _num_particles, real _eps){
#ifndef __CUDA_ARCH__
	cudaMalloc(&dev_ptr, sizeof(Box**));
	Box_GPU << <1, 1 >> >(dev_ptr, _center, _l_half,_w_half,_d_half, _T2, _T1, _D, _region, _permeability, num_particles, _eps);
#endif
	num_particles = _num_particles;
	center = _center;
	l_half = _l_half;
	w_half = _w_half;
	d_half = _d_half;
	D = _D;
	T2 = _T2;
	T1 = _T1;
	region = _region;
	cylEPS = _eps;

	length = d_half;

	right_end = center.z + length / 2;
	left_end = center.z - length / 2;
}








//__device__ __host__ ~Box(){};

__host__ Primitive** Box::devPointer() const{
	return (Primitive**) dev_ptr;
}

//this will need to be changed once we go to full generality
__device__ Vector3 Box::unifRand(curandState localState) const{

	Vector3 r;
	do{
		r.x = l_half*(2.0*curand_uniform(&localState) - 1) / 2.0 + center.x;
		r.y = w_half*(2.0*curand_uniform(&localState) - 1) / 2.0 + center.y;
		r.z = d_half*(2.0*curand_uniform(&localState) - 1) / 2.0 + center.z;
	} while (!inside(r));

	return r;
}

__host__ Vector3 Box::unifRandCPU() const{

	Vector3 r;
	do{
		r.x = l_half*(2.0*unifRandCPP() - 1) / 2.0 + center.x;
		r.y = w_half*(2.0*unifRandCPP() - 1) / 2.0 + center.y;
		r.z = d_half*(2.0*unifRandCPP() - 1) / 2.0 + center.z;
	} while (!inside(r));

	return r;
}


__device__ __host__ bool Box::inside(const Vector3 & r) const{

	return (abs(r.x - center.x) < l_half / 2)&& (abs(r.y - center.y) < w_half / 2) && (abs(r.z - center.z) < d_half / 2);
}

__device__ __host__ bool Box::inside_on(const Vector3 & r) const{

	const real cyc_x = abs(r.x - center.x);
	const real cyc_y = abs(r.y - center.y);
	const real cyc_z = abs(r.z - center.z);
	return ((cyc_x < l_half / 2 - EPSILON)&& (cyc_y < w_half / 2 - EPSILON)&& (cyc_z < d_half / 2 - EPSILON));
}

__device__ __host__ bool Box::inside_on_side(const Vector3 & r) const{

	const real cyc_x = abs(r.x - center.x);
	const real cyc_y = abs(r.y - center.y);
	const real cyc_z = abs(r.z - center.z);
	return ((cyc_x < l_half / 2 - EPSILON)&& (cyc_y < w_half / 2 - EPSILON) && (cyc_z < d_half / 2 - EPSILON));
}

__device__ __host__ bool Box::inside_on_end(const Vector3 & r) const{

	const real cyc_x = abs(r.x - center.x);
	const real cyc_y = abs(r.y - center.y);
	const real cyc_z = abs(r.z - center.z);
	return ((real_equal(cyc_x, l_half/2, cylEPS))&& (real_equal(cyc_y, w_half/2, cylEPS)) && (real_equal(cyc_z, d_half/2, cylEPS)));
}

__device__ __host__ bool Box::inside(real x, real y, real z) const{

	return (abs(x - center.x) < l_half / 2)&& (abs(y - center.y) < w_half / 2)&& (abs(z - center.z) < d_half / 2);
}











/*
	intersect: Determines if a particle has hit the side of the object.
	*/

__device__ __host__ bool Box::intersect(const Vector3 & ri, const Vector3 & rf, real & v, Vector3 & n) const{

	printf("Box::intersect is called########################################(JUNYAO)\n");



	//Particle is inside the cylinder and might hit the left end or particle is to the left of the cylinder and might hit the left end.
	if ((rf.z < left_end && inside_on(ri) == true) || (ri.z < left_end && rf.z > left_end)){
		return intersect_end(ri, rf, v, n, Vector3(0, 0, -1), left_end);
	} //Particle is inside the cylinder and might hit the right end or particle is to the right of the cylinder and might hit the right end.
	else if ((rf.z > right_end && inside_on(ri) == true) || (ri.z > right_end && rf.z < right_end)){
		return intersect_end(ri, rf, v, n, Vector3(0, 0, 1), right_end);
	} //Particle cannot possibly hit either end, but check if it hits the side.
	else {
		return intersect_side(ri, rf, v, n);
	}
}


__device__ __host__ bool Box::intersect_end(const Vector3 & ri, const Vector3 & rf, real & v, Vector3 & n, const Vector3 & n_dir, real end_z) const{
	Vector3 dr = rf - ri;
	//printf("End: %f\n", end_z);
	//printf("rf: %f %f %f\nri:%f %f %f\n", rf.x, rf.y, rf.z, ri.x, ri.y, ri.z);
	real line_param = (end_z - ri.z) / dr.z;
	//printf("Line_param = %f\n", line_param);
	real y_intersect = ri.y + dr.y * line_param;
	real x_intersect = ri.x + dr.x * line_param;
	//printf("y, x: %f %f\n", y_intersect, x_intersect);
	real rho = sqrt(pow(x_intersect - center.x, 2) + pow(y_intersect - center.y, 2));
	//printf("rho: %f\n", rho);

	//Particle is within the area of the cylinder end.
	if (rho <= radius){
		v = abs(end_z - ri.z) / abs(rf.z - ri.z);
		if (real_equal(v, 0.0, cylEPS)){//Then particle started on the wall and should move a full distance.
			return intersect_side(ri, rf, v, n);
		}
		Vector3 temp = (rf - ri)*v + ri;
		//printf("rfc: %f %f %f\n", temp.x, temp.y, temp.z);
		//printf("v: %f\n", v);
		n = n_dir;
		return true;
	} //Particle is outside the area of the cylinder end, but could possibly hit a cylinder side.
	else {
		return intersect_side(ri, rf, v, n);
	}
}

__device__ __host__ bool Box::intersect_side(const Vector3 & ri, const Vector3 & rf, real & v, Vector3 & n) const{

	Vector3 dr = rf - ri;
	real step_mag = dr.magnitude();

	// real a = dr.x*dr.x + dr.y*dr.y;
	// real b = 2*ri.x*dr.x + 2*ri.y*dr.y;
	// real c = ri.x*ri.x + ri.y*ri.y - radius*radius;

	real a = dr.x*dr.x + dr.y*dr.y;
	real b = 2.0*ri.x*dr.x - 2.0*dr.x*center.x + 2.0*ri.y*dr.y - 2.0*dr.y*center.y;
	real c = ri.x*ri.x + ri.y*ri.y - 2.0*ri.x*center.x - 2.0*ri.y*center.y + center.x*center.x + center.y*center.y - radius*radius;

	real q = -.5*(b + sgn(b)*sqrt(b*b - 4 * a*c));
	real root1 = q / a;
	real root2 = c / q;

	bool s1 = (root1 > 0.0 && root1 < 1.0 && b*b>4 * a*c && !real_equal(root1*step_mag, 0.0, cylEPS));
	bool s2 = (root2 > 0.0 && root2 < 1.0 && b*b>4 * a*c && !real_equal(root2*step_mag, 0.0, cylEPS));
	bool s3 = (fabs(root1) < fabs(root2));

	if ((s1 && s2 && s3) || (s1 && !s2)){
		v = root1;
		n = getNormalSide((rf - ri)*v + ri);
		return true;
	}

	else if ((s1 && s2 && !s3) || (s2 && !s1)){
		v = root2;
		n = getNormalSide((rf - ri)*v + ri);
		return true;
	}

	else {
		return false;
	}

}

//here r is a point on the surface
//Needs to be updated for length parameter
__device__ __host__ Vector3 Box::getNormal(const Vector3 & r) const{

	printf("Box::getNormal is called########################################(JUNYAO)\n");


	if (inside_on_side(r))
		return getNormalSide(r);
	else
		return getNormalEnd(r);
}

__device__ __host__ Vector3 Box::getNormalSide(const Vector3 & r) const{
	double n_x = r.x - center.x;
	double n_y = r.y - center.y;
	double mag = sqrt(n_x*n_x + n_y*n_y);
	return Vector3(n_x / mag, n_y / mag, 0.0);
}

__device__ __host__ Vector3 Box::getNormalEnd(const Vector3 & r) const{
	if (r.z < center.z)
		return Vector3(0.0,0.0,-1.0);
	else
		return Vector3(0.0,0.0,1.0);
}









__device__ __host__ real Box::getRadius() const{

	printf("Box::getRadius is called########################################(JUNYAO)\n");

	return radius;

}

__device__ __host__ int Box::getRegion(const Vector3 & r) const{

//	printf("Box::getRegion is called########################################(JUNYAO)\n");

	return region;
}

__device__ __host__  real Box::getT2(const Vector3 & r) const{

	printf("Box::getT2 is called########################################(JUNYAO)\n");

	if (inside(r)){
		return T2;
	}
	return -1.0;
}

__device__ __host__ real Box::getT2() const{
	return T2;
}

__device__ __host__ real Box::getT1() const{
	return T1;
}

__device__ __host__ real Box::getD(const Vector3 & r) const{


	printf("Box::getD is called########################################(JUNYAO)\n");
	if (inside(r)){
		return D;
	}
	return -1.0;
}

__device__ __host__ real Box::getD() const{
	return D;
}

__device__ __host__ real Box::getPermeability() const{
	return permeability;
}

__device__ __host__ Vector3 Box::getCenter() const{
	return Vector3(center.x, center.y, center.z);
}

__host__ void Box::setCenter(Vector3 v){
	center.x = v.x;
	center.y = v.y;
	center.z = v.z;
}

__host__ void Box::setRadius(real _r){

	printf("Box::setRadius is called########################################(JUNYAO)\n");
	radius = _r;
}

__host__ void Box::setEPS(real _cylEPS){
	printf("Box::setEPS is called########################################(JUNYAO)\n");
	cylEPS = _cylEPS;
}

__host__ void Box::setRegion(int _region){
	printf("Box::setRegion is called########################################(JUNYAO)\n");
	region = _region;
}

__device__ __host__ int Box::getRegion(){
	return region;
}

__device__ void Box::randUnif(Vector3 & r, curandState & localState) const{
	printf("Box::randUnif is called########################################(JUNYAO)\n");

	do {
		r = Vector3((2.0*curand_uniform(&localState) - 1.0)*radius, (2.0*curand_uniform(&localState) - 1.0)*radius, (2.0*curand_uniform(&localState) - 1.0)*length / 2) + getCenter();
	} while (!inside(r));
}

__host__ void Box::randUnif(Vector3 & r) const{
	printf("Box::randUnif2 is called########################################(JUNYAO)\n");

	do {
		r = Vector3((2.0*unifRandCPP() - 1.0)*radius, (2.0*unifRandCPP() - 1.0)*radius, length*(2.0*unifRandCPP() - 1) / 2.0) + getCenter();
	} while (!inside(r));
}






__global__ void Box_GPU(Box** obj_ptr, Vector3 _center, real _l_half,real _w_half, real _d_half, real _T2, real _T1, real _D, int _region, real _permeability, int num_particles, real _eps){
	if (threadIdx.x == 0 && blockIdx.x == 0)
		*obj_ptr = new Box(_center, _l_half,_w_half,_d_half, _T2, _T1, _D, _region, _permeability, num_particles, _eps);
}
