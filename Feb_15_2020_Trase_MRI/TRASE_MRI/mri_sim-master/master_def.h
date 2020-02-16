/*
 * master_def.h: Defines library wide macro definitions.
 *
 *  Created on: Dec 6, 2016
 *      Author: Michael Honke
 */

#ifndef MASTER_DEF_H_
#define MASTER_DEF_H_


//this whole simulator is using cm as length and ms as time, T as strength of the magnetic filed.

//Type Definitions
typedef float  real;

//Definitions
//#define NUM_SM 15				//for the GTX 1070 desktop
#define NUM_SM 15				//for the GTX 1070 laptop


//#define NO_DIFF
#define WARP_SIZE 32
#define PI 3.14159265359


//define the element of the sample
//#define GAMMA -203789.0 //rad / ms*T					//this is for (3)He
#define GAMMA 267513.0 //rad / ms*T						//this is for (1)H
#define EPSILON 5E-12
#define SIM_THREADS 128
#define RK4_RELAXATION
#define USE_RELAXATION
#define INITIALIZE_IN_REGION 1
//#define ALLOC_G
#define G_SHARED_SIZE 255
//#define MASS_DEBUG
#define Z_GRADS
#define CPU

#endif /* MASTER_DEF_H_ */
