/*
Sequence: Superclass of all scanner sequences. Sequences are very diverse 
and therefore this superclass describes the basic methods required by a 
sequence to run successfully in this simulator.
Author: Michael Honke
Date: Oct. 14, 2016
*/

#ifndef SEQUENCE_CUH
#define SEQUENCE_CUH

#include<cuda_runtime.h>

#include "../master_def.h"
#include "../util/vector3.cuh"
#include "../util/misc.cuh"
#include "device_launch_parameters.h"
#include "../params/simuParams.cuh"
#include "pulses.cuh"
#include"../util/recorder.h"


#include "../params/TRASE_Params.cuh"

class Sequence;

class Sequence{
protected:
	int n_sub_sequences;
	int readSteps;
	int readFactor;
	int steps;
	int num_pulses;
	SimuParams* par;

	Pulse** pulse;

	real TR;
	int phase_enc_offset;
	int thread_assign_tensors;

	Sequence** dev_ptr;

	__device__ __host__ Sequence(int n_sub_sequences, int num_pulses, real phase_enc_offset, int _local_res_x, SimuParams* par)
		: n_sub_sequences(n_sub_sequences),
		  num_pulses(num_pulses),
		  phase_enc_offset(phase_enc_offset),par(par),
		  TR(par->TR),
		  local_res_x(par->res_x),
		  local_res_y(par->res_y),
		  thread_assign_tensors(ceil(G_SHARED_SIZE / (real) SIM_THREADS))
	{
		_local_res_x == 0 ? local_res_x = par->res_x : local_res_x = _local_res_x;//Check if a subsequence or not.
//		steps = (TR/par->timestep)*local_res_x;
		pulse = new Pulse*[num_pulses];
		printf("Number of steps in sequence: %d\n", steps);

#if defined(ALLOC_G) && not defined (__CUDA_ARCH__)
		cudaMalloc((void**) &G_tensor_t_devptr, sizeof(real)*steps*9);
		cudaMalloc((void**) &RF_tensor_t_devptr, sizeof(real)*steps*3);

		//G_tensor_t = (real*) malloc(sizeof(real)*steps*9);
		//RF_tensor_t = (real*) malloc(sizeof(real)*steps*3);
		//printf("Pre-field allocation: %f MB\n", sizeof(real)*steps*12 / 1000000.0);
#endif
	}







//////////////////////////////second optimization
/*
	__device__ __host__ Sequence(int n_sub_sequences, int num_pulses, real phase_enc_offset, int _local_res_x, SimuParams* par,TRASE_Params* TRASE_par)
		: n_sub_sequences(n_sub_sequences),
		  num_pulses(num_pulses),
		  phase_enc_offset(phase_enc_offset),par(par),TRASE_par(TRASE_par),
		  TR(par->TR),
		  local_res_x(par->res_x),
		  local_res_y(par->res_y),
		  thread_assign_tensors(ceil(G_SHARED_SIZE / (real) SIM_THREADS))
	{
		_local_res_x == 0 ? local_res_x = par->res_x : local_res_x = _local_res_x;//Check if a subsequence or not.
//		steps = (TR/par->timestep)*local_res_x;
		pulse = new Pulse*[num_pulses];
		printf("Number of steps in sequence: %d\n", steps);
	}
	__host__ __device__ ~Sequence(void){
#if defined(ALLOC_G) && not defined (__CUDA_ARCH__)
		cudaFree(G_tensor_t_devptr);
		cudaFree(RF_tensor_t_devptr);
#endif
		free(pulse);
	}
*/






public:
	////////////////////////////////////////////////////////////////
	int local_res_x;
	int local_res_y;

	//use pointer to allocate a array
	real* array = new real[par->res_y];
	int* TRASE_last = new int[par->res_y];	//record the last read pulse
	int* TRASE_first = new int[par->res_y];	//record the first read pulse


//	TRASE_Params* TRASE_par;
	real pulse_gap;
	real time_gap;

	real pulse_duration;



	virtual __host__ const Sequence* getSubSequences(int i) const = 0;
	virtual __device__ __host__ int get_k_start() const = 0;
	virtual __device__ __host__ int get_k_end() const = 0;

	virtual __device__ __host__ real getReadStart(int start) const = 0;
	virtual __device__ __host__ real getReadFinish(int end) const = 0;

	virtual __device__ __host__ Vector3 getK(int time) const = 0;







///////////////////////////////////////////////TRASE

	__device__ int TRASE_No_Relaxation(real time,int pulse_num) const{


		if(pulse[pulse_num]->TRASE_on(time)){						//this loop take 0s
			return 1;
		}

		return 0;
	}


	__device__ int TRASE_pulse_switch(int pulse_num) const{

		return pulse[pulse_num]->pulse_switch;
	}


	__device__ real TRASE_seg_end_time(int pulse_num) const{

		return pulse[pulse_num]->end + time_gap;
	}




	__host__ int TRASE_No_Relaxation_CPU(real time,int pulse_num) const{


		if(pulse[pulse_num]->TRASE_on_CPU(time)){						//this loop take 0s
			return 1;
		}

		return 0;
	}






	__device__ Vector3 TRASE_getG(Vector3 r, real time,int pulse_num) const{

		return pulse[pulse_num]->TRASE_output(time,r);					//The GPU kernel already checked pulse_on function

	}

	__host__ Vector3 TRASE_getG_CPU(Vector3 r, real time,int pulse_num) const{

		return pulse[pulse_num]->TRASE_output_CPU(time,r);					//The GPU kernel already checked pulse_on function

	}




	__device__ real TRASE_90(){

		return pulse[0]->strength;
	}
	__host__ real TRASE_90_CPU()const{

		return pulse[0]->strength;

	}




	__device__ real TRASE_180(){

		return pulse[1]->strength;
	}
	__host__ real TRASE_180_CPU()const{

		return pulse[1]->strength;
	}





	__device__ int update_pulse_num(real time,int pulse_num){

		if(time < pulse[pulse_num]->end){

		}else{
			pulse_num++;
		}
		return pulse_num;


	}


	__host__ int update_pulse_num_CPU(real time,int pulse_num)const{

		if(time < pulse[pulse_num]->end){

		}else{
			pulse_num++;
		}
		return pulse_num;


	}

	//read immediately after the pulse
	__device__ real TRASE_getReadStart(int start) const{
		return pulse[start]->start;
	}
	__device__ real TRASE_getReadFinish(int end) const{
		return pulse[end]->end + (pulse_duration/2) ;
	}

	__device__ int TRASE_getReadFactor() const{
		return readFactor;
	}

	__device__ int TRASE_getSteps() const{
		return steps;
	}
	__host__ real TRASE_getReadStart_CPU(int start) const{
		return pulse[start]->start - pulse_gap/2;

		//return pulse[start]->start;
	}
	__host__ real TRASE_getReadFinish_CPU(int end) const{
		return pulse[end]->end + (time_gap);

		//return pulse[end]->end + (pulse_duration/2) ;
	}

	__host__ int TRASE_getReadFactor_CPU() const{
		return readFactor;
	}

	__host__ int TRASE_getSteps_CPU() const{
		return steps;
	}

	///////////////////////////////////////////////////////TRASE










	virtual __device__ __host__ int getSteps() const{
		return steps;
	}
	virtual __device__ __host__ int getReadFactor() const{
		return readFactor;
	}
	virtual __device__ __host__ int getReadSteps() const{
		return readSteps;
	}
	virtual __host__ int getNSubSequences(void) const{
		return n_sub_sequences;
	}
	virtual __host__ Sequence** devPointer() const{
		return dev_ptr;
	}
};

#endif
