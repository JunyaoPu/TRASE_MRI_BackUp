#ifndef TRASE_CU
#define TRASE_CU

#include "sequence.cuh"
#include "pulses.cuh"
#include <vector>
class TRASE : public Sequence{
private:
	TRASE* sub_seq;

	bool parallel = false;
	real readFinish;
	real readStart;
	real B0;
	real B1;
	int phase_steps;

//	real pulse_gap;
	int T_res_x;
	int T_res_y;

public:

	__device__ __host__ TRASE(SimuParams* par, int _phase_enc_offset = 0, int _local_res_x = 0);



	__device__ __host__ Vector3 getK(int readStep) const;
	__device__ __host__ int get_k_start() const;
	__device__ __host__ int get_k_end() const;
	__host__ const Sequence* getSubSequences(int i) const;
	__device__ __host__ real getReadStart(int start) const;
	__device__ __host__ real getReadFinish(int end) const;


};

#endif
