#ifndef PULSES_CUH
#define PULSES_CUH

#include "../master_def.h"
#include "../util/vector3.cuh"

class Pulse{
public:
	real start;
	real end;
	real duration;
	real strength;
	Vector3 bDir;
	Vector3 rDir;


/////reduction
	real angle;
	real w;
	Vector3 g;

	int pulse_switch;

	__device__ __host__ Pulse(real start, real duration, real strength, Vector3 bDir, Vector3 rDir);

	__device__ __host__ inline virtual bool on(real time) const{
		if (time >= start && time < end)
			return true;
		else
			return false;
	}







///////////////////////////////////////TRASE




	__device__ __host__ Pulse(real start, real duration, Vector3 _g, real angle, Vector3 B0);

//to check the global time is at the pulse time
	__device__ bool TRASE_on(real time) const{
		if (time >= start && time < end)
			return true;
		else
			return false;
	}



	__host__  bool TRASE_on_CPU(real time) const{
		if (time >= start && time < end)
			return true;
		else
			return false;
	}




//output the pulse filed
	__device__ Vector3 TRASE_output(real time, Vector3 r){

		real pulse_strength =2*strength*cos(w*time)*0.995;

		if(pulse_switch==0){


			return Vector3(pulse_strength, 0, 0);
		}else{

			return Vector3(pulse_strength*sin((g)*(r)), pulse_strength*cos((g)*(r)), 0);

		}



	}

	__host__ Vector3 TRASE_output_CPU(real time, Vector3 r){

		real pulse_strength =2*strength*cos(w*time)*0.995;

		if(pulse_switch==0){


			return Vector3(pulse_strength, 0, 0);
		}else{

			return Vector3(pulse_strength*sin((g)*(r)), pulse_strength*cos((g)*(r)), 0);

		}



	}
};







class RFflip : public Pulse{
public:

	__device__ __host__ RFflip(real start, real duration, Vector3 _g, real angle, Vector3 B0);


};


class RFflip_EXC : public Pulse{
public:

	__device__ __host__ RFflip_EXC(real start, real duration, Vector3 _g, real angle, Vector3 B0);


};


class RFflip_X : public Pulse{
	public:

		__device__ __host__ RFflip_X(real start, real duration, Vector3 _g, real angle, Vector3 B0);

};



class RFflip_Y : public Pulse{
	public:

		__device__ __host__ RFflip_Y(real start, real duration, Vector3 _g, real angle, Vector3 B0);

};





__device__ __host__ real trap(real local_strength, real ramp, real start, real end, real local_time);



#endif
