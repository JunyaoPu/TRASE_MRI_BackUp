//Main simulator macro definitions.
#include "master_def.h"

//Specific coil, sequence... for this simulation.
#include <iostream>
#include "sequence/GRE.cuh"
#include "coil/coil_ideal.cuh"
#include "scanner/scanner.cuh"
#include "primitives/CylinderXY.cuh"
#include "params/simuParams.cuh"
#include "util/recorder.h"
#include "util/vector3.cuh"

#include "params/TRASE_Params.cuh"
#include <time.h>


//#include "primitives/lattice.cuh"

void wait ( int seconds )
{
  clock_t endwait;
  endwait = clock () + seconds * CLOCKS_PER_SEC ;
  while (clock() < endwait) {}
}

void iteration(double _num){

	//Simulation properties.
	int num_par = 10240;

	SimuParams test_params(num_par, //Number of particles.							keep
		num_par,					//Number of particles per stream.				keep
		8,						//Sequence repeat time.								delete
		0.5,						//Sequence echo time.							delete
		0.001,						//Simulation timestep.							keep
		0,							//Number of particles to track continual, individual magnetization.				maybe not//n_mags_track
		Vector3(0, 0, 1),			//Initial magnetization vector.					keep
		Vector3(0, 0, 0.001),		//Main B0 field direction / strength.			keep
		65,							//(vertical) resolution.						keep(need to modify it)
		65,							//(horizontal) resolution.						keep(ntmi)
		5,							//(vertical) FOV.								keep()
		5,							//(horizontal) FOV.								keep()
		1.005,																		//dont need it anymore
		_num										//dont need it anymore
		);

	TRASE_Params test_TRASE(&test_params);

	Coil_Ideal test_coil;
	GRE test_sequence(&test_params);


	Lattice test_lattice(3.0, 3.0, 0.5, 100.0, 100.0, 0, 8);
	Scanner test_scanner(test_sequence, test_coil, test_params, test_lattice,test_TRASE);


	Cylinder_XY test_primitive(Vector3(-1, -1, 0), 0.5, 0.2, 0.5, 1.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive);
	Cylinder_XY test_primitive_2(Vector3(1, -1, 0), 0.5, 0.2, 0.5, 1.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive_2);
	Cylinder_XY test_primitive_nose(Vector3(0, 0, 0), 0.5, 0.2, 0.5, 1.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive_nose);
	Cylinder_XY test_primitive_mouth(Vector3(-1.25, 1, 0), 0.25, 0.2, 0.5, 1.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive_mouth);
	Cylinder_XY test_primitive_mouth_2(Vector3(-0.60, 1.25, 0), 0.25, 0.2, 0.5, 1.0, 0.00001, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive_mouth_2);
	Cylinder_XY test_primitive_mouth_3(Vector3(0, 1.4, 0), 0.25, 0.2, 0.5, 1.0, 0.00002, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive_mouth_3);
	Cylinder_XY test_primitive_mouth_4(Vector3(0.60, 1.25, 0), 0.25, 0.2, 0.5, 1.0, 0.00003, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive_mouth_4);
	Cylinder_XY test_primitive_mouth_5(Vector3(1.25, 1, 0), 0.25, 0.2, 0.5, 1.0, 0.00004, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive_mouth_5);

	//Run the scan!
	test_scanner.scan();

	cudaDeviceSynchronize();
	cudaDeviceReset();

}

int main(){

	for (double i = 25; i < 26;i++){

		iteration(i);

		wait(15);
	}


	return 0;
}
