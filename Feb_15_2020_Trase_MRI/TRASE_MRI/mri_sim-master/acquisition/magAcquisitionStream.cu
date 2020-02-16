#include "magAcquisitionStream.cuh"
#include "../kernels/kernelMagLattice.cuh"


///////////////////////////////////////////////////////optimization
//single sample
__host__ Scan::Scan(
	magAcquisition* acq,
	SimuParams* par,
	TRASE_Params* TRASE_par,
	const Sequence* host_seq,
	const Primitive* basis,
	const Coil** coil,
	int devNum,
	const std::vector<int> devSMP,
	cudaStream_t stream
	):
	acq(acq),
	par(par),
	TRASE_par(TRASE_par),
	host_seq(host_seq),
	basis(basis),
	coil(coil),
	devNum(devNum),
	devSMP(&devSMP),
	stream(stream),
	measurements(par->measurements),
	number_of_particles(par->particles_per_stream)
{
	num_blocks = par->blocks;
	//signal of one block
	signal_x.malloc(host_seq->getReadSteps()*num_blocks, stream);
	signal_y.malloc(host_seq->getReadSteps()*num_blocks, stream);
	signal_z.malloc(host_seq->getReadSteps()*num_blocks, stream);

	//signal of steps
	signal_x_total.malloc(host_seq->getReadSteps(), stream);
	signal_y_total.malloc(host_seq->getReadSteps(), stream);
	signal_z_total.malloc(host_seq->getReadSteps(), stream);


	dev_states.malloc(number_of_particles, stream);
	dev_par.malloc(stream);
	dev_par = *par;

	safe_cuda(cudaGetLastError(), "Malloc");
	cudaStreamSynchronize(stream);
	dev_par.copyToDevice();
	safe_cuda(cudaGetLastError(), "Malloc2");
	setup_kernel <<< num_blocks, SIM_THREADS, 0, stream>>> (dev_states.getPointer(), par->getSeed());
	safe_cuda(cudaGetLastError(), "Setup");
}






//multiple sample
__host__ Scan::Scan(
	magAcquisition* acq,
	SimuParams* par,

	TRASE_Params* TRASE_par,


	const Sequence* host_seq,
	Lattice* lattice,
	Primitive*** basis_dev_pointers,
	const Coil** coil,
	int devNum,
	const std::vector<int> devSMP,
	cudaStream_t stream
	):
	acq(acq),
	par(par),

	TRASE_par(TRASE_par),

	host_seq(host_seq),
	lattice(lattice),
	basis_dev_pointers(basis_dev_pointers),
	coil(coil),
	devNum(devNum),
	devSMP(&devSMP),
	stream(stream),
	measurements(par->measurements),
	number_of_particles(par->particles_per_stream)
{
	size_t size_basis_dev_pointers = lattice->getBasisSize() * sizeof(Primitive**);
	cudaMalloc((void****)&basis_dev_pointers_pointer, size_basis_dev_pointers);
	cudaMemcpy(basis_dev_pointers_pointer, basis_dev_pointers, size_basis_dev_pointers, cudaMemcpyHostToDevice);
	num_blocks = par->blocks;
	signal_x.malloc(host_seq->getReadSteps()*num_blocks, stream);
	signal_y.malloc(host_seq->getReadSteps()*num_blocks, stream);
	signal_z.malloc(host_seq->getReadSteps()*num_blocks, stream);
	signal_x_total.malloc(host_seq->getReadSteps(), stream);
	signal_y_total.malloc(host_seq->getReadSteps(), stream);
	signal_z_total.malloc(host_seq->getReadSteps(), stream);
	dev_states.malloc(number_of_particles, stream);
	dev_par.malloc(stream);
	dev_par = *par;

	safe_cuda(cudaGetLastError(), "Malloc");
	cudaStreamSynchronize(stream);
	dev_par.copyToDevice();
	safe_cuda(cudaGetLastError(), "Malloc2");
	setup_kernel <<< num_blocks, SIM_THREADS, 0, stream>>> (dev_states.getPointer(), par->getSeed());
	safe_cuda(cudaGetLastError(), "Setup");
}
///////////////////////////////////////////////////////////////////









__host__ void Scan::runScan(){


	//copy data
	/*
	real h_seg_time[par->res_y];
	int h_read_start[par->res_y];
	int h_read_end[par->res_y];
	*/

	int h_last[par->res_y];
	int h_first[par->res_y];

	for (int i=0; i <par->res_y;i++){
		/*
		h_seg_time[i] = host_seq->array[i];
		h_read_start[i] = TRASE_par->read_start[i];
		h_read_end[i] = TRASE_par->read_end[i];
		*/

		h_last[i] = host_seq->TRASE_last[i];
		h_first[i] = host_seq->TRASE_first[i];
	}

	//allocate cuda memory
/*
	real *d_seg_time;
	int *d_read_start;
	int *d_read_end;
	int *d_pulse_switch;
*/
	int *d_last;
	int *d_first;


//	int size = sizeof(real);
	int size_int = sizeof(int);
/*
	cudaMalloc((void**)&d_seg_time,(par->res_y)*size);
	cudaMalloc((void**)&d_read_start,(par->res_y)*size_int);
	cudaMalloc((void**)&d_read_end,(par->res_y)*size_int);
	cudaMalloc((void**)&d_pulse_switch,(par->TRASE_total)*size_int);
*/
	cudaMalloc((void**)&d_last,(par->res_y)*size_int);
	cudaMalloc((void**)&d_first,(par->res_y)*size_int);

/*
	cudaMemcpy(d_seg_time,h_seg_time,size*(par->res_y),cudaMemcpyHostToDevice);
	cudaMemcpy(d_read_start,h_read_start,size_int*(par->res_y),cudaMemcpyHostToDevice);
	cudaMemcpy(d_read_end,h_read_end,size_int*(par->res_y),cudaMemcpyHostToDevice);
	cudaMemcpy(d_pulse_switch, TRASE_par->pulse_switch,size_int*(par->TRASE_total),cudaMemcpyHostToDevice);
*/
	cudaMemcpy(d_last,h_last,size_int*(par->res_y),cudaMemcpyHostToDevice);
	cudaMemcpy(d_first,h_first,size_int*(par->res_y),cudaMemcpyHostToDevice);
/*
	delete []host_seq->array;
	delete []TRASE_par->read_start;
	delete []TRASE_par->read_end;
	delete []TRASE_par->pulse_switch;
*/

//	updateWalkersMag<false, false> << < 1, 1, 0, stream >> > (
	updateWalkersMag<false, false> << < num_blocks, SIM_THREADS, 0, stream >> > (
		dev_par.getPointer(),
		basis->devPointer(),
		host_seq->devPointer(),
		coil,
		dev_states.getPointer(),
		0,//par->n_mags_track,
		0,
		0,
		0,
		signal_x.getPointer(),
		signal_y.getPointer(),
		signal_z.getPointer(),
		d_last,
		d_first
		);


}






__host__ void Scan::run_scan_lattice(){

	int h_last[par->res_y];
	int h_first[par->res_y];

	for (int i=0; i <par->res_y;i++){

		h_last[i] = host_seq->TRASE_last[i];
		h_first[i] = host_seq->TRASE_first[i];
	}

	//allocate cuda memory

	int *d_last;
	int *d_first;


//	int size = sizeof(real);
	int size_int = sizeof(int);

	cudaMalloc((void**)&d_last,(par->res_y)*size_int);
	cudaMalloc((void**)&d_first,(par->res_y)*size_int);

	cudaMemcpy(d_last,h_last,size_int*(par->res_y),cudaMemcpyHostToDevice);
	cudaMemcpy(d_first,h_first,size_int*(par->res_y),cudaMemcpyHostToDevice);

//	update_walkers_lattice_mag<false, false> << < 1, 1, 0, stream >> > (
	update_walkers_lattice_mag<false, false> << < num_blocks, SIM_THREADS, 0, stream >> > (
		dev_par.getPointer(),
		lattice->devPointer(),
		basis_dev_pointers_pointer,
		host_seq->devPointer(),
		coil,
		dev_states.getPointer(),
		0,//par->n_mags_track,
		0,
		0,
		0,
		signal_x.getPointer(),
		signal_y.getPointer(),
		signal_z.getPointer(),
		d_last,
		d_first
		);


}

__host__ void Scan::saveScan(){
	int threads_sum = 512;
	signal_x.sum(signal_x_total, threads_sum, NUM_SM, host_seq->getReadSteps(), num_blocks, stream);
	signal_y.sum(signal_y_total, threads_sum, NUM_SM, host_seq->getReadSteps(), num_blocks, stream);
	signal_z.sum(signal_z_total, threads_sum, NUM_SM, host_seq->getReadSteps(), num_blocks, stream);
	safe_cuda(cudaDeviceSynchronize());
	signal_x_total.copyFromDevice();
	signal_y_total.copyFromDevice();
	signal_z_total.copyFromDevice();
	safe_cuda(cudaDeviceSynchronize());
	signal_x_total.copyTo(acq->get_signal_x());
	signal_y_total.copyTo(acq->get_signal_y());
	signal_z_total.copyTo(acq->get_signal_z());
}
