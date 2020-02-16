#ifndef K_SPACE_CU
#define K_SPACE_CU

#include <cufft.h>
#include "../util/recorder.h"
#include <fstream>
#include<vector>

class kSpace{
public:

	////////////////////////////////////
	const int dim_x;
	const int dim_y;
	///////////////////////////////////
	cufftDoubleComplex *dev_space;
	cufftDoubleComplex **host_space;
	cufftDoubleComplex *dev_result;
	cufftDoubleComplex **host_result;


	cufftDoubleComplex *Tdev_space;
	cufftDoubleComplex **Thost_space;
	cufftDoubleComplex *Tdev_result;
	cufftDoubleComplex **Thost_result;
	int Tdim_x;
	int Tdim_y;
	size_t Thost_space_pitch;
	size_t Tdev_space_pitch;



	size_t host_space_pitch;
	size_t dev_space_pitch;
	double* mag_image;

	kSpace(const int dim_x, const int dim_y);
	size_t index(int x, int y);
	double get_Mx(int x, int y);
	double get_My(int x, int y);
	void set_Mx(int x, int y, double val);
	void set_My(int x, int y, double val);
	void get_fft();

//additional function for TRASE
	void TRASE_rearrangeMx(int res_x, int res_y)
	{
		printf("the rearrangement is started Mx\n");
		int dim_x=res_x;
		int dim_y=res_y;
		int N = (int)(dim_y/2);
		int M = (int)(dim_x/2);

		//x-axis
		vector<real> total;
		vector<real> vec1;
		vector<real> vec2;
		vector<real> vec3;


		for(int i = 0; i<dim_x;i++){
			for(int j=0; j<dim_y;j++){
				total.push_back(host_space[i][j].x);
			}
		}

		int num_echoAB = int(dim_y/2)*2 + 2;
		int num_trainAB = int(dim_x/2);
		int total_echoAB = num_echoAB*num_trainAB;

		for(int i = 0; i < total_echoAB;i++){
			vec1.push_back(total[i]);
		}

		int num_echoBA = int(dim_y/2)*2;
		int num_trainBA = int(dim_x/2);
		int total_echoBA = num_echoBA*num_trainBA;
		for(int i = total_echoAB; i < total_echoAB+total_echoBA;i++){
			vec2.push_back(total[i]);
		}

		for(int i = total_echoAB+total_echoBA;i<total.size();i++){
			vec3.push_back(total[i]);
		}
	//////////////////////////////////////////////
		vector<real> vec1R;
		vector<real> vec1L;


		for(int i = 0; i<vec1.size();i++){
			if(i%2){
				vec1R.push_back(vec1[i]);
			}else{
				vec1L.push_back(vec1[i]);
			}

		}
		vector<real> vec2R;
		vector<real> vec2L;

		for(int i = 0; i<vec2.size();i++){
			if(i%2){
				vec2R.push_back(vec2[i]);
			}else{
				vec2L.push_back(vec2[i]);
			}

		}
		vector<real> vec3R;
		vector<real> vec3L;

		for(int i = 0; i<vec3.size();i++){
			if(i%2){
				vec3L.push_back(vec3[i]);
			}else{
				vec3R.push_back(vec3[i]);
			}

		}
	///////////////////////////////////////refill
	///center line(GOOD)
		int center_axis = ((dim_x+1)/2)-1;
		int index=0;
		for(int j=0;j<vec3R.size();j++){
			host_space[center_axis][index].x = vec3R[vec3R.size()-1-j];
			index++;
		}

		for(int j=0;j<vec3L.size();j++){
			host_space[center_axis][index].x = vec3L[j];				//modified
			index++;
		}
	////above the center line

		for(int i=1;i<=center_axis;i++)
		{
			index=0;

			for(int j=0; j<N+1; j++){
				host_space[center_axis-M-1+i][index].x = vec1R[vec1R.size()-1-j-(N+1)*(i-1)];   //center_axis-M-1+i

				index++;
			}
			for(int j=0; j<N; j++){
				host_space[center_axis-i][index].x = vec2L[j+(N)*(i-1)];
				index++;
			}
		}
	////below the center line
		for(int i=1;i<=center_axis;i++)
		{
			index=0;

			for(int j=0; j<N; j++){
				host_space[center_axis+M+1-i][index].x = vec2R[vec2R.size()-1-j-(N)*(i-1)];
				index++;
			}
			for(int j=0; j<N+1; j++){
				host_space[center_axis+i][index].x = vec1L[j+(N+1)*(i-1)];
				index++;
			}
		}

	}


	void TRASE_rearrangeMy(int res_x, int res_y)
	{
		printf("the rearrangement is started My\n");
		int dim_x=res_x;
		int dim_y=res_y;
		int N = (int)(dim_y/2);
		int M = (int)(dim_x/2);

		//x-axis
		vector<real> total;
		vector<real> vec1;
		vector<real> vec2;
		vector<real> vec3;


		for(int i = 0; i<dim_x;i++){
			for(int j=0; j<dim_y;j++){
				total.push_back(host_space[i][j].y);
			}
		}

		int num_echoAB = int(dim_y/2)*2 + 2;
		int num_trainAB = int(dim_x/2);
		int total_echoAB = num_echoAB*num_trainAB;

		for(int i = 0; i < total_echoAB;i++){
			vec1.push_back(total[i]);
		}

		int num_echoBA = int(dim_y/2)*2;
		int num_trainBA = int(dim_x/2);
		int total_echoBA = num_echoBA*num_trainBA;
		for(int i = total_echoAB; i < total_echoAB+total_echoBA;i++){
			vec2.push_back(total[i]);
		}

		for(int i = total_echoAB+total_echoBA;i<total.size();i++){
			vec3.push_back(total[i]);
		}
	//////////////////////////////////////////////
		vector<real> vec1R;
		vector<real> vec1L;


		for(int i = 0; i<vec1.size();i++){
			if(i%2){
				vec1R.push_back(vec1[i]);
			}else{
				vec1L.push_back(vec1[i]);
			}

		}
		vector<real> vec2R;
		vector<real> vec2L;

		for(int i = 0; i<vec2.size();i++){
			if(i%2){
				vec2R.push_back(vec2[i]);
			}else{
				vec2L.push_back(vec2[i]);
			}

		}
		vector<real> vec3R;
		vector<real> vec3L;

		for(int i = 0; i<vec3.size();i++){
			if(i%2){
				vec3L.push_back(vec3[i]);
			}else{
				vec3R.push_back(vec3[i]);
			}

		}
	///////////////////////////////////////refill
	///center line(GOOD)
		int center_axis = ((dim_x+1)/2)-1;
		int index=0;
		for(int j=0;j<vec3R.size();j++){
			host_space[center_axis][index].y = vec3R[vec3R.size()-1-j];
			index++;
		}

		for(int j=0;j<vec3L.size();j++){
			host_space[center_axis][index].y = vec3L[j];				//modified
			index++;
		}
	////above the center line

		for(int i=1;i<=center_axis;i++)
		{
			index=0;

			for(int j=0; j<N+1; j++){
				host_space[center_axis-M-1+i][index].y = vec1R[vec1R.size()-1-j-(N+1)*(i-1)];   //center_axis-M-1+i

				index++;
			}
			for(int j=0; j<N; j++){
				host_space[center_axis-i][index].y = vec2L[j+(N)*(i-1)];
				index++;
			}
		}
	////below the center line
		for(int i=1;i<=center_axis;i++)
		{
			index=0;

			for(int j=0; j<N; j++){
				host_space[center_axis+M+1-i][index].y = vec2R[vec2R.size()-1-j-(N)*(i-1)];
				index++;
			}
			for(int j=0; j<N+1; j++){
				host_space[center_axis+i][index].y = vec1L[j+(N+1)*(i-1)];
				index++;
			}
		}

	}



	void TRASE_phase_shiftingMx(int res_x, int res_y)
	{
		int dim_x=res_x;
		int dim_y=res_y;

		printf("phase_shiftingMx\n");
		vector<real> total;


		for(int i = 0; i<dim_x;i++){
			for(int j=0; j<dim_y;j++){
				total.push_back(host_space[i][j].x);
			}
		}

		for(int i = 0; i<dim_x;i++){
			for(int j=0; j<dim_y;j++){

	//			cout<<pow(-1.0, i+j)<<"kx+ky is "<<i+j<<endl;

				total[i*dim_y+j] = total[i*dim_y+j]*pow(-1.0, i+j);

				host_space[i][j].x = total[i*dim_y+j];
			}
		}

	}

	void TRASE_phase_shiftingMy(int res_x, int res_y)
	{
		int dim_x=res_x;
		int dim_y=res_y;

		printf("phase_shiftingMy\n");
		vector<real> total;


		for(int i = 0; i<dim_x;i++){
			for(int j=0; j<dim_y;j++){
				total.push_back(host_space[i][j].y);
			}
		}

		for(int i = 0; i<dim_x;i++){
			for(int j=0; j<dim_y;j++){

	//			cout<<pow(-1.0, i+j)<<"kx+ky is "<<i+j<<endl;

				total[i*dim_y+j] = total[i*dim_y+j]*pow(-1.0, i+j);

				host_space[i][j].y = total[i*dim_y+j];
			}
		}

	}


	void TRASE_transferMx(){

		for(int i = 0; i<64;i++){
			for(int j=0; j<64;j++){
				Thost_space[i][j].x = host_space[i][j].x;
			}
		}
	}

	void TRASE_transferMy(){

		for(int i = 0; i<64;i++){
			for(int j=0; j<64;j++){
				Thost_space[i][j].y = host_space[i][j].y;
			}
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
};

#endif
