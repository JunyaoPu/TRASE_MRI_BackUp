#ifndef _CPU_KERNELS_
#define _CPU_KERNELS_

//#include "util/deviates.h"
#include "../params/simuParams.cuh"
//#include "../blochdiff/blochdiff.cuh"
#include "../kernels/boundaryCheck.cuh"
#include "../coil/coil.cuh"
#include "../primitives/primitive.cuh"

void updateWalkersMagCPU(SimuParams *par, Primitive* basis, const Sequence* B,
		Coil* coil, int n_mags_track, real *signal_x, real *signal_y,
		real *signal_z,

		real *d_seg_time,
		int *d_read_start,
		int *d_read_end,
		int *d_pulse_switch

		);
#endif
