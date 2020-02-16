#include "CPUkernels.cuh"
#include <iostream>

void updateWalkersMagCPU(SimuParams *par,
		Primitive* basis,
		const Sequence* B,
		Coil* coil,
		int n_mags_track,
		real *signal_x,
		real *signal_y,
		real *signal_z,

		real *d_seg_time,
		int *d_read_start,
		int *d_read_end,
		int *d_pulse_switch
						) {

//overall variable
	printf("the CPU kernel is called\n\n\n\n\n");
	real w = (par->B0).z * GAMMA;
	real dg=0.22;						//14*14 FOV
	real strength90=(B)->TRASE_90_CPU();
	real strength180=(B)->TRASE_180_CPU();
	Vector3 B0=par->B0;								//constant
	real time_step= par->timestep;					//constant




	int d_seg=0;
	int pulse_num=0;
	int pulse_pick= 0;		// 0 , 1 , 2, 3


	//loop the number of particles
	for (int tid = 0; tid < par->number_of_particles; tid++) {
//	for (int tid = 0; tid < 1; tid++) {
		printf("Current particle on CPU is: %d\n", tid);


		real Mx = 0;
		real My = 0;
		real Mz = 0;



		//reset the particle variable
		d_seg=0;
		pulse_num=0;
		pulse_pick= 0;		// 0 , 1 , 2, 3


		//pre-diffusion
		real phi, theta;
		real speed = sqrt(6.0 * basis->getD() / par->timestep);



		//generate the position
		Vector3 r = basis->unifRandCPU();
		//printf("%f, %f, %f\n", r.x, r.y, r.z);


		//initialize the M
		Mx = 0;
		My = 0;
		Mz = 1;







		//loop is here
		////////////////////////TRASE
		int s = 0;
		Vector3 TRASE_M,k1,k2,k3,k4,finaldM;
		Vector3 v1,v2,v3;
		///////////////////////TRASE
		for (int i = 0; i < (B)->TRASE_getSteps_CPU(); i++) {


			real time = i * par->timestep;





/*//no diffusion
		//Diffusion
			Vector3 ri = r;
			phi = 2.0 * PI * unifRandCPP();
			theta = acos(2.0 * unifRandCPP() - 1);
			r += Vector3(speed * par->timestep * sin(theta) * cos(phi),
					speed * par->timestep * sin(theta) * sin(phi),
					speed * par->timestep * cos(theta));
#if defined SPECULAR_REFLECTION
			boundaryNormalCPU(ri,r, speed, basis, par->timestep);
#else
			if (!basis->inside(r)) {
				r = ri;
			}
#endif
*/




///////////////////////////////////////////////////////////////////////////////////////////TRASE
		//Reset the mag at the first pulse of each echo_train
				if(time < d_seg_time[d_seg]){
				}else{
					d_seg++;

					Mx = 0;
					My = 0;
					Mz = 1;
				}

		//update the pulse number
				if(pulse_num < par->TRASE_total-1){
					pulse_num = (B)->update_pulse_num_CPU(time,pulse_num);
				}


				pulse_pick = d_pulse_switch[pulse_num];
/////////////////////////////////////////////////////////////////////////////////////////TRASE


/*
#if defined RK4_RELAXATION


		TRASE_M.x=Mx;
		TRASE_M.y=My;
		TRASE_M.z=Mz;

		k1=((TRASE_M%((B)->TRASE_getG_CPU( r, time,pulse_num) + B0))*GAMMA)*time_step;								//1143
		k2 = (((TRASE_M + k1*.5)%((B)->TRASE_getG_CPU( r, time + .5*time_step,pulse_num) + B0))*GAMMA)*time_step;	//1784
		k3 = (((TRASE_M + k2*.5)% ((B)->TRASE_getG_CPU( r, time + .5*time_step, pulse_num) + B0))*GAMMA)*time_step;//14
		k4 = (((TRASE_M + k3)%((B)->TRASE_getG_CPU( r, time + time_step, pulse_num) + B0))*GAMMA)*time_step;		//9

		finaldM = (k1 + k2*2.0 + k3*2.0 + k4)*(1.0 / 6.0);

		Mx += finaldM.x;
		My += finaldM.y;
		Mz += finaldM.z;

#endif
*/






//////////////////////////////////////////////////////////////////////////////////////////////TRASE
			//X-Y Plane		x-y field only
			if(((B)->TRASE_No_Relaxation_CPU(time,pulse_num))){


				TRASE_M.x=Mx;
				TRASE_M.y=My;
				TRASE_M.z=Mz;

				Vector3 G;
				real pulse_strength;


				real trig_num1=w*time;
				real trig_num2=w*(time + .5*time_step);
				real trig_num3=w*(time + time_step);



				if(pulse_pick==0){			//Exciting pulse

					pulse_strength =2*strength90*cos(trig_num1)*0.995;
					v1=Vector3(pulse_strength, 0, 0)+B0;

					pulse_strength =2*strength90*cos(trig_num2)*0.995;
					v2=Vector3(pulse_strength, 0, 0)+B0;

					pulse_strength =2*strength90*cos(trig_num3)*0.995;
					v3=Vector3(pulse_strength, 0, 0)+B0;


				}else if(pulse_pick == 1){		//refocusing pulse with no phase


					pulse_strength =2*strength180*cos(trig_num1)*0.995;
					G=Vector3(0, pulse_strength, 0);
					v1=G+B0;

					pulse_strength =2*strength180*cos(trig_num2)*0.995;
					G=Vector3(0, pulse_strength, 0);
					v2=G+B0;

					pulse_strength =2*strength180*cos(trig_num3)*0.995;
					G=Vector3(0, pulse_strength, 0);
					v3=G+B0;





				}else if(pulse_pick ==2){		//refocusing pulse with X phase

					real pulse_X= (dg)*(r.x);

					pulse_strength =2*strength180*cos(trig_num1)*0.995;
					G=Vector3(pulse_strength*sin(pulse_X), pulse_strength*cos(pulse_X), 0);
					v1=G+B0;

					pulse_strength =2*strength180*cos(trig_num2)*0.995;
					G=Vector3(pulse_strength*sin(pulse_X), pulse_strength*cos(pulse_X), 0);
					v2=G+B0;

					pulse_strength =2*strength180*cos(trig_num3)*0.995;
					G=Vector3(pulse_strength*sin(pulse_X), pulse_strength*cos(pulse_X), 0);
					v3=G+B0;

				}else{	//refocusing pulse with Y phase				//here reduced 4s for the simulator
					real pulse_Y=(dg)*(r.y);

					pulse_strength =2*strength180*cos(trig_num1)*0.995;
					G=Vector3(pulse_strength*sin(pulse_Y), pulse_strength*cos(pulse_Y), 0);
					v1=G+B0;

					pulse_strength =2*strength180*cos(trig_num2)*0.995;
					G=Vector3(pulse_strength*sin(pulse_Y), pulse_strength*cos(pulse_Y), 0);
					v2=G+B0;

					pulse_strength =2*strength180*cos(trig_num3)*0.995;
					G=Vector3(pulse_strength*sin(pulse_Y), pulse_strength*cos(pulse_Y), 0);
					v3=G+B0;
				}

				k1=( TRASE_M % v1 )*GAMMA*time_step;
	 			k2 = ( (TRASE_M + k1*.5)% v2 )*GAMMA*time_step;
				k3 = ((TRASE_M + k2*.5)% v2)*GAMMA*time_step;
				k4 = ( (TRASE_M + k3)%v3 )*GAMMA*time_step;


	 			finaldM = (k1 + k2*2.0 + k3*2.0 + k4)*(1.0 / 6.0);
				Mx += finaldM.x;
				My += finaldM.y;
				Mz += finaldM.z;

				}
///////////////////////////////////////////////////////////////////////////////////////TRASE







//////////////////////////////////////////////////////////////////////////////////////TRASE
			if (time >= (B)->TRASE_getReadStart_CPU(d_read_start[d_seg]) &&
				time <= (B)->TRASE_getReadFinish_CPU(d_read_end[d_seg]) &&
				((int)(i - (B)->TRASE_getReadStart_CPU(d_read_start[d_seg])/time_step))!=0&&
				( (int)(i - (B)->TRASE_getReadStart_CPU(d_read_start[d_seg])/time_step)) % (B)->TRASE_getReadFactor_CPU() == 0){
/////////////////////////////////////////////////////////////////////////////////////TRASE

				//Save the total signal from this block to global memory for later summation.
				signal_x[s] += Mx * cos(w * time) - My * sin(w * time);
				signal_y[s] += Mx * sin(w * time) + My * cos(w * time);
				signal_z[s] += Mz;
				s++;
			}

		}

	}

}
