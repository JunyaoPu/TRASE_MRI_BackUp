#ifndef _SIMUPARAMS_H_
#define _SIMUPARAMS_H_

#include <time.h>
#include "../master_def.h"
#include "../util/vector3.cuh"

class SimuParams {

public:

	int number_of_particles;
	int particles_per_stream;
	bool particle_concurrency;
	int num_streams;
	int steps;
	int measurements;
	int n_mags_track;
	unsigned long long seed;
	int blocks;
	int res_x;
	int res_y;
	int seed_offset;
	real TR;
	real TE;
	real timestep;
	real mx_initial;
	real my_initial;
	real mz_initial;
	real time_end;
	real FOVx;
	real FOVy;
	Vector3 B0;

//////////////////////////////////////////////////////////////TRASE MRI
	double ratio;

	int TRASE_total;
//////////////////////////////////////////////////////////////TRASE MRI


	SimuParams* devPointer;

public:
	__host__ SimuParams();

	__host__ SimuParams(int _number_of_particles,
		int _particles_per_stream,
		real _TR,
		real _TE,
		real _timestep,
		int _n_mags_track,
		Vector3 m_initial,
		Vector3 _B0,
		int _res_x,
		int _res_y,
		real _FOVx,
		real _FOVy,
		double _ratio
		);




//////////////////////////////////////////////////////////////TRASE MRI
//calculating the total pulse number in echo-train sequence
	__host__ int TRASE_total_pulse(int res_x, int res_y){
		int total_pulse = 0;
		int accumulation = 0;
		for(int i=0; i < (int)(res_x/2);i++){

			total_pulse += 3+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}

		accumulation=0;

		for(int i=0; i < (res_x)-1-(int)(res_x/2);i++){

			total_pulse += 2+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}
		return total_pulse += 2+(2*(int)(res_y/2));

	}
///////////////////////////////////////////////////////////////


	__host__ int getSeed();

	__host__ void copyToDevice();

};

#endif
