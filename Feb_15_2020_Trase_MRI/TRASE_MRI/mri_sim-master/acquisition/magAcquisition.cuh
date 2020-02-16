#ifndef _MAG_ACQUISITION_H_
#define _MAG_ACQUISITION_H_

#include "../params/simuParams.cuh"
#include "../sequence/sequence.cuh"
#include "../util/recorder.h"
#include <vector>
#include <string>

class magAcquisition {

private:

	int numOfMeasurements;
	int numOfSteps;
	int n_mags_track = 0;
	int lastAllocMeasurement;
	int seed;
	int readSteps;
	int steps;

	std::vector<real> signal_x;
	std::vector<real> signal_y;
	std::vector<real> signal_z;
	std::vector<real> mx_tracked;
	std::vector<real> my_tracked;
	std::vector<real> mz_tracked;

	real ADC;
	real ADCmeansquare;
	int points;

public:

	magAcquisition(const SimuParams* params, const Sequence* _sequence){
		points = 0;
		readSteps = _sequence->getReadSteps();

		signal_x = std::vector<real>(readSteps);
		signal_y = std::vector<real>(readSteps);
		signal_z = std::vector<real>(readSteps);

		numOfMeasurements = params->measurements;
		seed = params->seed;
		numOfSteps = params->steps;
		lastAllocMeasurement = 0;
		steps = _sequence->getSteps();
	}



	std::vector<real> & get_signal_x(){
		return signal_x;
	}

	std::vector<real> & get_signal_y(){
		return signal_y;
	}

	std::vector<real> & get_signal_z(){
		return signal_z;
	}

	int & getSeed(){
		return seed;
	}

};

#endif
