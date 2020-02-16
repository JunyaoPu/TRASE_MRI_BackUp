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



	Lattice test_lattice(3.0*3, 3.0*3, 0.5*3, 100.0, 100.0, 0, 3*8);
	Scanner test_scanner(test_sequence, test_coil, test_params, test_lattice,test_TRASE);


//new 24_box

	Box test_primitive1(Vector3(-0.65,1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive1);
	Box test_primitive2(Vector3(-0.65,0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive2);
	Box test_primitive3(Vector3(-0.65,-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive3);

	Box test_primitive4(Vector3(-0.65+(-1.3*1),1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive4);
	Box test_primitive5(Vector3(-0.65+(-1.3*1),0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive5);
	Box test_primitive6(Vector3(-0.65+(-1.3*1),-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive6);

	Box test_primitive7(Vector3(-0.65+(-1.3*2),1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive7);
	Box test_primitive8(Vector3(-0.65+(-1.3*2),0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive8);
	Box test_primitive9(Vector3(-0.65+(-1.3*2),-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive9);

	Box test_primitive10(Vector3(-0.65+(-1.3*3),1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive10);
	Box test_primitive11(Vector3(-0.65+(-1.3*3),0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive11);
	Box test_primitive12(Vector3(-0.65+(-1.3*3),-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive12);













	Box test_primitive13(Vector3(0.65+(1.3*0),1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive13);
	Box test_primitive14(Vector3(0.65+(1.3*0),0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive14);
	Box test_primitive15(Vector3(0.65+(1.3*0),-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive15);

	Box test_primitive16(Vector3(0.65+(1.3*1),1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive16);
	Box test_primitive17(Vector3(0.65+(1.3*1),0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive17);
	Box test_primitive18(Vector3(0.65+(1.3*1),-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive18);

	Box test_primitive19(Vector3(0.65+(1.3*2),1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive19);
	Box test_primitive20(Vector3(0.65+(1.3*2),0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive20);
	Box test_primitive21(Vector3(0.65+(1.3*2),-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive21);

	Box test_primitive22(Vector3(0.65+(1.3*3),1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive22);
	Box test_primitive23(Vector3(0.65+(1.3*3),0.0,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive23);
	Box test_primitive24(Vector3(0.65+(1.3*3),-1.3,0.0), 1.0,1.0,1.0, 2.0, 4.0, 0, 1, 0, num_par);
	test_scanner.add_primitive(test_primitive24);


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
	for (real i = 18; i < 19;){

		iteration(0);

		i+=100;
		wait(15);
	}


	return 0;
}
