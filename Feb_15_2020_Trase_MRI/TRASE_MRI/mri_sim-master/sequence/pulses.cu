#include "pulses.cuh"

__device__ __host__ Pulse::Pulse(real start, real duration, real strength, Vector3 bDir, Vector3 rDir)
: start(start), duration(duration), strength(strength), bDir(bDir), rDir(rDir){
	end = start + duration;
#ifndef __CUDA_ARCH__
	printf("Pulse start: %f\nPulse end: %f\n================\n", start, end);
#endif
}

/////////////////////////////////////////////////////////TRASE
__device__ __host__ Pulse::Pulse(real start, real duration, Vector3 _g, real angle, Vector3 B0)
: Pulse(start, duration, 0, Vector3(0,0,0), Vector3(0,0,0)){
}


//sub_pulse for TRASE
__device__ __host__ RFflip::RFflip(real start, real duration, Vector3 _g, real angle, Vector3 B0)
:Pulse(start, duration, _g, angle,B0){
//	printf("The function is called \n\n\n");

	strength = angle / fabs(GAMMA*duration);
	w = B0.magnitude() * GAMMA;
	g=_g;
	pulse_switch =1;
}


//excited pulse
__device__ __host__ RFflip_EXC::RFflip_EXC(real start, real duration, Vector3 _g, real angle, Vector3 B0)
:Pulse(start, duration, _g, angle,B0){
	strength = angle / fabs(GAMMA*duration);
	w = B0.magnitude() * GAMMA;
	g=_g;
	pulse_switch =0;
}


//////////////////////
__device__ __host__ RFflip_X::RFflip_X(real start, real duration, Vector3 _g, real angle, Vector3 B0)
:Pulse(start, duration, _g, angle,B0){
	strength = angle / fabs(GAMMA*duration);
	w = B0.magnitude() * GAMMA;
	g=_g;
	pulse_switch =2;
}



__device__ __host__ RFflip_Y::RFflip_Y(real start, real duration, Vector3 _g, real angle, Vector3 B0)
:Pulse(start, duration, _g, angle,B0){
	strength = angle / fabs(GAMMA*duration);
	w = B0.magnitude() * GAMMA;
	g=_g;
	pulse_switch =3;
}



__device__ __host__ real trap(real local_strength, real ramp, real start, real end, real local_time){
	if (local_time - start <= ramp)
		return (1 / ramp)*(local_time-start) * local_strength;
	else if (local_time - start > ramp && local_time <= (end - ramp))
		return local_strength;
	else
		return (1 - (1 / ramp)*(local_time - end + ramp))*local_strength;
}
