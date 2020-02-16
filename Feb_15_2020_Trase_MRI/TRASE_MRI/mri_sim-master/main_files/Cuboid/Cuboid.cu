//Main simulator library.
#include "master_def.h"

//Specific coil, sequence... for this simulation.
#include <iostream>
#include "sequence/GRE.cuh"
#include "coil/coil_ideal.cuh"
#include "scanner/scanner.cuh"
#include "primitives/CylinderXY.cuh"
#include "primitives/Box.cuh"
#include "params/simuParams.cuh"
#include "util/recorder.h"
#include "util/vector3.cuh"


#include <time.h>
#include "params/TRASE_Params.cuh"
#include "primitives/Box.cuh"

void wait ( int seconds )
{
  clock_t endwait;
  endwait = clock () + seconds * CLOCKS_PER_SEC ;
  while (clock() < endwait) {}
}


void iteration(real _num){

	//Simulation properties.
	int num_par = 10240;

	SimuParams test_params(num_par, //Number of particles.
		num_par,					//Number of particles per stream.
		8,						//Sequence repeat time.
		0.5,						//Sequence echo time.
		0.001,						//Simulation timestep.
		0,							//Number of particles to track continual, individual magnetization.
		Vector3(0, 0, 1),			//Initial magnetization vector.
		Vector3(0, 0, 0.001),		//Main B0 field direction / strength.
		65,							//(vertical) resolution.
		65,							//(horizontal) resolution.
		5,							//(vertical) FOV.
		5,							//(horizontal) FOV.
		1.005,
		_num
		);

	TRASE_Params test_TRASE(&test_params);


	Coil_Ideal test_coil;
	GRE test_sequence(&test_params);
	Scanner test_scanner(test_sequence, test_coil, test_params,test_TRASE);
	Box test_primitive(Vector3(0.0,0.0,0.0), 2.0*5,2.0*2,2.0, 2.0, 4.0, 0, 0, 0, num_par);
	test_scanner.add_primitive(test_primitive);

	//
	test_scanner.scan();
	//


	//Post simulation commands.
	test_scanner.acqs[0]->save_signal("signal");
	test_scanner.acqs[0]->save_tracked("test_track");
	cudaDeviceSynchronize();
	cudaDeviceReset();

	cout<<"End Here@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"<<endl;


}

int main(){
	//g=25 is better than 30
	for (real i = 25; i < 26;){

		iteration(i);

		i+=100;
		wait(15);
	}


	return 0;
}
