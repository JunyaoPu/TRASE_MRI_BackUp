
#ifndef _Update_Mag_H_
#define _Update_Mag_H_


#include <cuda.h>
#include <cuda_runtime.h>
#include "../util/vector3.cuh"





//with Relaxation
__device__ void Update_Mag(real &Mx,
		real &My,
		real &Mz,
		real w,
		real time,
		real time_step,
		real strength90,
		real strength180,
		real dg,
		Vector3 B0,
		Vector3 r,
		int pulse_pick,
		real T1,
		real T2
		);


__device__ Vector3 pulse_Exc(real strength, real trig_num);

__device__ Vector3 pulse_ref(real strength, real trig_num);

__device__ Vector3 pulse_axis(real strength, real trig_num, real axis);



/*

__device__ void Update_Mag(real *Mx,
		real *My,
		real *Mz,
		real w,
		real time,
		real time_step,
		real strength90,
		real strength180,
		real dg,
		Vector3 B0,
		Vector3 r,
		int pulse_pick
		)

{

	Vector3 TRASE_M,k1,k2,k3,k4,finaldM;
	Vector3 v1,v2,v3;

	Vector3 G;
	real pulse_strength;


	TRASE_M.x = *Mx;
	TRASE_M.y = *My;
	TRASE_M.z = *Mz;

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
	*Mx += finaldM.x;
	*My += finaldM.y;
	*Mz += finaldM.z;



}
*/

#endif
