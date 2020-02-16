

#ifndef TRASE_PARAMS_CUH_
#define TRASE_PARAMS_CUH_

#include "simuParams.cuh"

class TRASE_Params {
public:

	int check =0 ;

	real* seg_time;		//real* array = new real[par->res_y];

	int* first_pulse;
	int* last_pulse;

	int* read_start;
	int* read_end;

	int x;
	int y;

	int* pulse_switch;

	//the last read pulse of each echo train
	int TRASE_end[65]={0};




	__host__ TRASE_Params(SimuParams* par);

	__host__ void Echo_train(SimuParams* par);				//generate the echo_train




	__host__ void set_first_pulse();
	__host__ void set_last_pulse();
	__host__ void set_read_start();
	__host__ void set_read_end();


	__host__ int TRASE_first_pulse(int seg, int res_x, int res_y);
	__host__ int TRASE_num_pulse(int seg, int res_x, int res_y);

	__host__ int TRASE_read_start(int seg, int x,int y);
	__host__ int TRASE_read_end(int seg, int x, int y);






};


#endif /* TRASE_PARAMS_CUH_ */

