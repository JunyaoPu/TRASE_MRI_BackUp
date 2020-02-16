#include "magAcquisitionStreamCPU.cuh"

__host__ ScanCPU::ScanCPU(){}
__host__ ScanCPU::ScanCPU(
	magAcquisition* acq,
	SimuParams* par,

	TRASE_Params* TRASE_par,

	const Sequence* host_seq,
	Primitive* basis,
	Coil* coil





	):
	acq(acq),
	par(par),

	TRASE_par(TRASE_par),

	host_seq(host_seq),
	basis(basis),
	coil(coil),
	measurements(par->measurements),
	number_of_particles(par->particles_per_stream)
{
	signal_x = new real[host_seq->getReadSteps()];
	signal_y = new real[host_seq->getReadSteps()];
	signal_z = new real[host_seq->getReadSteps()];



}

__host__ void ScanCPU::runScan(){



	real h_seg_time[par->res_y];

	int h_read_start[par->res_y];
	int h_read_end[par->res_y];

//	int h_pulse_switch[10];

	for (int i=0; i <par->res_y;i++){

		h_seg_time[i] = host_seq->array[i];

		h_read_start[i] = TRASE_par->read_start[i];
		h_read_end[i] = TRASE_par->read_end[i];
	}



	updateWalkersMagCPU(
		par,
		basis,
		host_seq,
		coil,
		par->n_mags_track,
		signal_x,
		signal_y,
		signal_z,



		h_seg_time,
		h_read_start,
		h_read_end,
		TRASE_par->pulse_switch

		);
}

__host__ void ScanCPU::saveScan(){
	for (int i = 0; i < host_seq->getReadSteps(); i++){
		acq->get_signal_x()[i] = (signal_x[i]);
		acq->get_signal_y()[i] = (signal_y[i]);
		acq->get_signal_z()[i] = (signal_z[i]);
	}
}
