#ifndef _kernelMagLattice_H_
#define _kernelMagLattice_H_

#include "../master_def.h"
#include "../params/simuParams.cuh"
//#include "../blochdiff/blochdiff.cuh"
#include "../kernels/boundaryCheck.cuh"
#include "../coil/coil.cuh"
#include "../primitives/primitive.cuh"
#include "../primitives/lattice.cuh"
#include <cub/cub.cuh>

#include "../blochdiff/Update_Mag.cuh"

template <bool trackingM, bool trackingX>
__global__ void update_walkers_lattice_mag(
	SimuParams *par,
	Lattice **lat,
	Primitive*** basis,
	Sequence** B,
	const Coil** coil,
	curandState* globalState,
	int n_mags_track,
	real *Mx_track,
	real *My_track,
	real *Mz_track,
	real *signal_x,
	real *signal_y,
	real *signal_z,
	int *d_last,
	int *d_first
	)
{
	//number of the echo-train segment
	int d_seg=0;
	//number of the pulse
	int pulse_num=0;

	//must use shared memory
	//parameters for TRASE mri
	__shared__ real strength90;
	__shared__ real strength180;
	__shared__ Vector3 B0;			//it reduce 2s
	__shared__ real time_step;
	__shared__ int TRASE_getSteps;


	//FOV
//	real dg=0.65;			//this is for 5*5 cm FOV
	real dg=0.22;			//14*14 FOV



	__shared__ int shared_read_start[65];
	__shared__ int shared_read_end[65];

	//shared memory
	for(int i=0;i<par->res_y;i++)
	{
		shared_read_start[i]=d_first[i];
		shared_read_end[i]=d_last[i];



		B0=par->B0;
		time_step = par->timestep;

		strength90=(*B)->TRASE_90() *0.995;
		strength180=(*B)->TRASE_180() *0.995;

		TRASE_getSteps=(*B)->TRASE_getSteps();

	}

	__syncthreads();

	//dont need to be shared memory
	real w = (par->B0).z * GAMMA;









//	printf("the function is called\n");

	typedef cub::BlockReduce<real, SIM_THREADS> BlockReduce;
	__shared__ typename BlockReduce::TempStorage temp_storage;

	const unsigned int tid = threadIdx.x + blockIdx.x*blockDim.x;
	curandState localState = globalState[tid];
	real Mx, My, Mz;
	real phi, theta, speed;
	Vector3 r, r_unbounded;
	real T1, T2, T2avg;

#ifdef INITIALIZE_IN_REGION
(*lat)->initializeInRegion(basis,localState,r, INITIALIZE_IN_REGION);
#else
(*lat)->initializeUniformly(r,localState);
#endif

	r_unbounded = r;
	speed = sqrt(6.0*(*lat)->getD(basis, r) / par->timestep);

	T1 = (*lat)->getT2(basis,r);
	T2 = (*lat)->getT1(basis,r);

	for (int i = 0; i < par->measurements; i++){

		Mx = par->mx_initial;
		My = par->my_initial;
		Mz = par->mz_initial;
	}











	int s = 0;
	Vector3 TRASE_M,k1,k2,k3,k4,finaldM;
	Vector3 v1,v2,v3;
	for (int i = 0; i < TRASE_getSteps; i++){
		real time = i * par->timestep;


		//update the pulse number
		if(pulse_num < par->TRASE_total-1){
			pulse_num = (*B)->update_pulse_num(time,pulse_num);
		}

		//new
		if(time < (*B)->TRASE_seg_end_time(shared_read_end[d_seg])){
		}else{
			d_seg++;

			Mx = 0;
			My = 0;
			Mz = 1;
		}







//this part is for diffusion
		Vector3 ri = r;
		phi = 2.0*PI*curand_uniform(&localState);
		theta = acos(2.0*curand_uniform(&localState) - 1);
		r += Vector3(speed*par->timestep*sin(theta)*cos(phi), speed*par->timestep*sin(theta)*sin(phi), speed*par->timestep*cos(theta));


//Relaxation for multiple sample
#if defined USE_RELAXATION
#if defined USE_PERMEABLE
	real T2_i = lat->getT2(basis,ri);
	real T2_f = lat->getT2(basis,r);
	T2 = ((accumtime*T2_i) + ((par->timestep - accumtime)*T2_f))/par->timestep
	real T1_i = lat->getT1(basis,ri);
	real T1_f = lat->getT1(basis,r);
	T1 = ((accumtime*T1_i) + ((par->timestep - accumtime)*T1_f))/par->timestep
#else
	T2 = (*lat)->getT2(basis, ri);
	T1 = (*lat)->getT1(basis, ri);
#endif
#endif

	(*lat)->correctBoundary(r);




		for (int j = 0; j < par->measurements; j++){

			//X-Y Plane	with rotating frame
			if(((*B)->TRASE_No_Relaxation(time,pulse_num))){

				TRASE_M.x=Mx;
				TRASE_M.y=My;
				TRASE_M.z=Mz;

				Vector3 G;

				real trig_num1=w*time;
				real trig_num2=w*(time + .5*time_step);
				real trig_num3=w*(time + time_step);

				//Exciting pulse		tip on + x-axis(apply on  -y-axis)
				if((*B)->TRASE_pulse_switch(pulse_num)==0){

					v1=pulse_Exc(strength90, trig_num1)+B0;

					v2=pulse_Exc(strength90, trig_num2)+B0;

					v3=pulse_Exc(strength90, trig_num3)+B0;

				//refocusing pulse with no phase	apply on  +x-axis
				}else if((*B)->TRASE_pulse_switch(pulse_num) == 1){

					v1=pulse_ref(strength180, trig_num1)+B0;

					v2=pulse_ref(strength180, trig_num2)+B0;

					v3=pulse_ref(strength180, trig_num3)+B0;

				//refocusing pulse with X phase				on +x axis
				}else if((*B)->TRASE_pulse_switch(pulse_num) ==2){

					real pulse_X= (dg)*(r.x);

					v1=pulse_axis(strength180, trig_num1, pulse_X)+B0;


					v2=pulse_axis(strength180, trig_num2, pulse_X)+B0;


					v3=pulse_axis(strength180, trig_num3, pulse_X)+B0;



				//refocusing pulse with Y phase
				}else{


					real pulse_Y=(dg)*(r.y);


					v1=pulse_axis(strength180, trig_num1, pulse_Y)+B0;

					v2=pulse_axis(strength180, trig_num2, pulse_Y)+B0;

					v3=pulse_axis(strength180, trig_num3, pulse_Y)+B0;
				}

				/*
				k1=( TRASE_M % v1 )*GAMMA*time_step;
	 			k2 = ( (TRASE_M + k1*.5)% v2 )*GAMMA*time_step;
				k3 = ((TRASE_M + k2*.5)% v2)*GAMMA*time_step;
				k4 = ( (TRASE_M + k3)%v3 )*GAMMA*time_step;
				*/

				//relaxation
				k1=((TRASE_M % v1)*GAMMA- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;
	 			k2 = (((TRASE_M + k1*.5)% v2 )*GAMMA- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;
				k3 = (((TRASE_M + k2*.5)% v2)*GAMMA- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;
				k4 = (((TRASE_M + k3)%v3 )*GAMMA- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;




	 			finaldM = (k1 + k2*2.0 + k3*2.0 + k4)*(1.0 / 6.0);
				Mx += finaldM.x;
				My += finaldM.y;
				Mz += finaldM.z;

				}


		}




		//new
		if (time >= (*B)->TRASE_getReadStart(shared_read_start[d_seg]) &&
			time <= (*B)->TRASE_getReadFinish(shared_read_end[d_seg]) &&
			((int)(i - (*B)->TRASE_getReadStart(shared_read_start[d_seg])/time_step))!=0&&
			( (int)(i - (*B)->TRASE_getReadStart(shared_read_start[d_seg])/time_step)) % (*B)->TRASE_getReadFactor() == 0){
			__syncthreads();

			real signal_x_block = BlockReduce(temp_storage).Sum(Mx*cos(w*time) - My*sin(w*time));
			real signal_y_block = BlockReduce(temp_storage).Sum(Mx*sin(w*time) + My*cos(w*time));
			real signal_z_block = BlockReduce(temp_storage).Sum(Mz);

			if (threadIdx.x == 0){
				signal_x[s * par->blocks + blockIdx.x] = signal_x_block;
				signal_y[s * par->blocks + blockIdx.x] = signal_y_block;
				signal_z[s * par->blocks + blockIdx.x] = signal_z_block;
				s++;
			}
		}

	}
	//globalState[tid] = localState;
}

#endif
