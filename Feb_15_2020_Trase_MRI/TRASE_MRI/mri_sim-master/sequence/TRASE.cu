#include "TRASE.cuh"
#include "pulses.cuh"



__global__ void TRASE_GPU(Sequence** obj_ptr, SimuParams* par, int phase_enc_offset = 0, int _local_res_x = 0);



__device__ __host__ TRASE::TRASE(SimuParams* par, int _phase_enc_offset, int _local_res_x) : Sequence(1,par->TRASE_total, phase_enc_offset, _local_res_x, par){


	phase_enc_offset = _phase_enc_offset;
	readSteps = local_res_x * par->res_y;

	T_res_x = par->res_x;
	T_res_y = par->res_y;


	real pulse_duration = 0.2;					//0.025
	pulse_gap = 0.00;				//0.01
	readFactor = (pulse_gap + pulse_duration)/par->timestep;



//	real FOV_ratio=1;
//	real dg = 0.65/FOV_ratio;



//those variables are for saving the initial echo-train time
	time_gap = 0.1;
	//time_gap is time between each each train
	int array_index = 0;
	real initial_time = 0.0;


	int onedex = 2;
	int num_ratio = 0;
/////A-C-(AC)-(AB)-A









//GIVE THE SIMULATOR STEPS
		steps = (initial_time/par->timestep);
		printf("number of simulator steps %d(JUNYAO)\n",steps);



#ifndef __CUDA_ARCH__
	safe_cuda(cudaMalloc(&dev_ptr, sizeof(TRASE**)));
	TRASE_GPU << <1, 1 >> >(dev_ptr, par->devPointer, _phase_enc_offset, _local_res_x);
#ifdef ALLOC_G
	make_tensors();
#endif
#endif
}


__device__ __host__ Vector3 TRASE::getK(int readStep) const{
	int k_y = readStep % par->res_y;
	int k_x = readStep / par->res_y;

	return Vector3(k_x, k_y, 0);
}




__device__ __host__ int TRASE::get_k_start() const{
	return phase_enc_offset*par->res_y;
}

__device__ __host__ int TRASE::get_k_end() const{
	return (local_res_x+phase_enc_offset) * par->res_y;
}




__host__ const Sequence* TRASE::getSubSequences(int i) const{
	if (parallel)
		return &sub_seq[i];
	else
		return this;
}




__device__ __host__ real TRASE::getReadStart(int start) const{

	return pulse[start]->start - pulse_gap/2;
}

__device__ __host__ real TRASE::getReadFinish(int end) const{

	return pulse[end]->end + (time_gap);
}




//what is the point of this function?
__global__ void TRASE_GPU(Sequence** obj_ptr, SimuParams* par, int _phase_enc_offset, int _local_res_x){
	*obj_ptr = new TRASE(par, _phase_enc_offset, _local_res_x);
}

