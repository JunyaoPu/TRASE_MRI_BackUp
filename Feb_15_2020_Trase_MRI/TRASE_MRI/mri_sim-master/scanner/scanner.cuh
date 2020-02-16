#ifndef SCANNER_CUH
#define SCANNER_CUH

/*
 * TODO: Move unnecessary #includes to .cu file.
 */

#include "../util/vector3.cuh"
#include "../sequence/sequence.cuh"
#include "../acquisition/magAcquisitionStream.cuh"
#include "../acquisition/magAcquisitionStreamCPU.cuh"
#include "../coil/coil.cuh"
#include "../primitives/primitive.cuh"
#include "k_space.cuh"

#include "../params/TRASE_Params.cuh"

class magAcquisition;
class Sequence;
class Coil;
class Primitive;
class Lattice;

class Scanner{
public:



	Scanner(Sequence& sequence,
			Coil& coil,
			SimuParams& params,
			TRASE_Params& TRASE_params
	);

	Scanner(Sequence& sequence,
			Coil& coil,
			SimuParams& params,
			Lattice& lattice,
			TRASE_Params& TRASE_params
	);

	kSpace* scan_k;
	std::vector<magAcquisition*> acqs;
	Sequence* sequence;
	Coil* coil;
	SimuParams* params;
	Lattice* lattice;
	bool lattice_present;
	std::vector<Primitive*> primitives;

	TRASE_Params* TRASE_params;


	bool scan();

	bool scan_lattice();
	bool scan_single_basis();
	bool scanCPU();

	bool add_primitive(Primitive& new_primitive);
	bool make_k_space(magAcquisition *acq, const Sequence *seq);
};

#endif
