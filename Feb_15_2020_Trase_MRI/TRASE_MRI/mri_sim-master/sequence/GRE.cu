#include "GRE.cuh"
#include "pulses.cuh"



__global__ void GRE_GPU(Sequence** obj_ptr, SimuParams* par, int phase_enc_offset = 0, int _local_res_x = 0);



__device__ __host__ GRE::GRE(SimuParams* par, int _phase_enc_offset, int _local_res_x) : Sequence(1,par->TRASE_total, phase_enc_offset, _local_res_x, par){

	printf("the value of the phase and local res x is %d, %d\n",_phase_enc_offset,_phase_enc_offset);


	phase_enc_offset = _phase_enc_offset;
	readSteps = local_res_x * par->res_y;

	T_res_x = par->res_x;
	T_res_y = par->res_y;


	pulse_duration = 0.2;					//0.025
	//pulse_gap is the time between each pulse
	pulse_gap = 0.0;				//0.01

	//readFactor = (pulse_gap + pulse_duration)/par->timestep;	//read between pulse_gap
	readFactor = (pulse_duration)/par->timestep;				//read immediately after the pulse


	Vector3 A(0,0,0);
	Vector3 B(0,0,0);
	Vector3 C(0,0,0);

	//time_gap is time between each train
	time_gap = 0.1;


	real initial_time = 0.0;
	int onedex = 2;
	int num_ratio = 0;

	int last_pulse_index = 0;





/////A-C-(AC)-(AB)-A			take int(N/2)+2 signals
	for(int num_TR = 0; num_TR<(int)(par->res_x/2);num_TR++)
	{
		onedex = 2;
		pulse[0+num_ratio] = new RFflip_EXC(0.0+initial_time, pulse_duration, A,(PI/2), par-> B0);					//11		//RF_GradientX_A(0, 0.01, Vector3(0,0,1),PI/2, par-> B0);
		//read data
		pulse[1+num_ratio] = new RFflip_Y(pulse[num_ratio]->end + pulse_gap, pulse_duration, C,(par->ratio*PI), par-> B0);								//RF_GradientX_C(pulse[0]->start + (TRASE_TE/2), 0.01, Vector3(0,0,1),PI, par-> B0);

		for(int i =0; i < num_TR; i++)
		{
			pulse[onedex+num_ratio] = new RFflip(pulse[onedex+num_ratio-1]->end + pulse_gap, pulse_duration, A,(par->ratio*PI), par-> B0);			//12		//RF_GradientX_A(pulse[onedex-1]->start + TRASE_TE, 0.01, Vector3(0,0,1),PI, par-> B0);

			pulse[onedex+1+num_ratio] = new RFflip_Y(pulse[onedex+num_ratio]->end + pulse_gap, pulse_duration, C,(par->ratio*PI), par-> B0);		//13		//RF_GradientX_C(pulse[onedex]->start + TRASE_TE, 0.01, Vector3(0,0,1),PI, par-> B0);

			onedex+=2;
		}
		for(int i =0; i < (int)(par->res_y/2); i++)					//here take N/2 signal from the simulator
		{
			pulse[onedex+num_ratio] = new RFflip(pulse[onedex+num_ratio-1]->end + pulse_gap, pulse_duration, A,(par->ratio*PI), par-> B0);						//RF_GradientX_A(pulse[onedex-1]->start + TRASE_TE, 0.01, Vector3(0,0,1),PI, par-> B0);
			pulse[onedex+1+num_ratio] = new RFflip_X(pulse[onedex+num_ratio]->end + pulse_gap, pulse_duration, B,(par->ratio*PI), par-> B0);					//RF_GradientX_A(pulse[onedex]->start + TRASE_TE, 0.01, Vector3(0,0,1),PI, par-> B0);
			onedex+=2;
		}
		pulse[onedex+num_ratio] = new RFflip(pulse[onedex+num_ratio-1]->end + pulse_gap, pulse_duration, A,(par->ratio*PI), par-> B0);
		//record the last read pulse
		TRASE_last[last_pulse_index] = onedex+num_ratio;
		TRASE_first[last_pulse_index] = TRASE_last[last_pulse_index] - (par->res_y);
		last_pulse_index++;


		initial_time = pulse[onedex+num_ratio]->end + time_gap;


		num_ratio +=(2+(num_TR*2)+((int)(par->res_y/2))*2)+1;
	}








//A-C-(AC)-(BA)-A		take int(N/2) signals
	for(int num_TR = 0; num_TR < (par->res_x)-1-(int)(par->res_x/2);num_TR++)
	{
		onedex = 2;
		pulse[0+num_ratio] = new RFflip_EXC(0+initial_time, pulse_duration, A,(PI/2), par-> B0);					//11
		pulse[1+num_ratio] = new RFflip_Y(pulse[num_ratio]->end + pulse_gap, pulse_duration, C,(par->ratio*PI), par-> B0);
		for(int i =0; i < num_TR; i++)
		{
			pulse[onedex+num_ratio] = new RFflip(pulse[onedex+num_ratio-1]->end + pulse_gap, pulse_duration, A,(par->ratio*PI), par-> B0);			//12
			pulse[onedex+1+num_ratio] =  new RFflip_Y(pulse[onedex+num_ratio]->end + pulse_gap, pulse_duration, C,(par->ratio*PI), par-> B0);		//13
			onedex+=2;
		}

		for(int i =0; i < (int)(par->res_y/2); i++)					//here take N/2 signal from the simulator
		{
			pulse[onedex+num_ratio] = new RFflip_X(pulse[onedex+num_ratio-1]->end + pulse_gap, pulse_duration, B,(par->ratio*PI), par-> B0);
			//read data
			pulse[onedex+1+num_ratio] = new RFflip(pulse[onedex+num_ratio]->end + pulse_gap, pulse_duration, A,(par->ratio*PI), par-> B0);
			onedex+=2;
		}

		//record the last read pulse
		TRASE_last[last_pulse_index] = onedex+1+num_ratio - 2;
		TRASE_first[last_pulse_index] = TRASE_last[last_pulse_index] - (par->res_y -2);
		last_pulse_index++;


		initial_time = pulse[(onedex-2)+1+num_ratio]->end + time_gap;

		num_ratio +=(2+(num_TR*2)+((int)(par->res_y/2))*2);
	}











//k-space center	A-(AB)-A   take int(N/2)+1 signals
	onedex = 1;
	pulse[0+num_ratio] = new RFflip_EXC(0+initial_time, pulse_duration, A,(PI/2), par-> B0);


	//read data

	for(int i =0; i < (int)(par->res_y/2); i++)
	{
		//printf("The last pulse is %d\n",onedex+num_ratio);
		pulse[onedex+num_ratio] = new RFflip(pulse[onedex+num_ratio-1]->end + pulse_gap, pulse_duration, A,(par->ratio*PI), par-> B0);
		pulse[onedex+1+num_ratio] = new RFflip_X(pulse[onedex+num_ratio]->end + pulse_gap, pulse_duration,B,(par->ratio*PI), par-> B0);
		onedex +=2;
	}
	pulse[onedex+num_ratio] = new RFflip(pulse[onedex+num_ratio-1]->end + pulse_gap, pulse_duration, A,(par->ratio*PI), par-> B0);



	//record the last read pulse
	TRASE_last[last_pulse_index] = onedex+num_ratio;
	TRASE_first[last_pulse_index] = TRASE_last[last_pulse_index] - (par->res_y -1);

	initial_time = pulse[onedex+num_ratio]->end + time_gap;

//GIVE THE SIMULATOR STEPS
	steps = (initial_time/par->timestep);
	printf("number of simulator steps %d(JUNYAO)\n",steps);


#ifndef __CUDA_ARCH__
	safe_cuda(cudaMalloc(&dev_ptr, sizeof(GRE**)));
	GRE_GPU << <1, 1 >> >(dev_ptr, par->devPointer, _phase_enc_offset, _local_res_x);
#ifdef ALLOC_G
	make_tensors();
#endif
#endif
}


__device__ __host__ Vector3 GRE::getK(int readStep) const{
	int k_y = readStep % par->res_y;
	int k_x = readStep / par->res_y;

	return Vector3(k_x, k_y, 0);
}




__device__ __host__ int GRE::get_k_start() const{
	return phase_enc_offset*par->res_y;
}

__device__ __host__ int GRE::get_k_end() const{
	return (local_res_x+phase_enc_offset) * par->res_y;
}




__host__ const Sequence* GRE::getSubSequences(int i) const{
	if (parallel)
		return &sub_seq[i];
	else
		return this;
}

__device__ __host__ real GRE::getReadStart(int start) const{

	return pulse[start]->start - pulse_gap;
}

__device__ __host__ real GRE::getReadFinish(int end) const{

	return pulse[end]->end + (time_gap);
}




//what is the point of this function?
__global__ void GRE_GPU(Sequence** obj_ptr, SimuParams* par, int _phase_enc_offset, int _local_res_x){
	*obj_ptr = new GRE(par, _phase_enc_offset, _local_res_x);
}

