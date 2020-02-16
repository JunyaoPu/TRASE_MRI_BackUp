

#include "TRASE_Params.cuh"

//allocate memory
__host__ TRASE_Params::TRASE_Params(SimuParams* par)
{

	x=par->res_x;
	y=par->res_y;

	seg_time = new real[y];

	first_pulse = new int[y];
	last_pulse = new int[y];

	read_start = new int[y];
	read_end = new int[y];



	pulse_switch =new int[par->TRASE_total];






	set_first_pulse();
	set_last_pulse();
	set_read_start();
	set_read_end();



	Echo_train(par);
}









//set up the data by the host
__host__ void TRASE_Params::set_first_pulse()
{
	for(int i=0; i<y;i++)
	{
		first_pulse[i] = TRASE_first_pulse(i,x,y);
	}
}

__host__ void TRASE_Params::set_last_pulse()
{

	for(int i=0; i<y;i++)
	{
		last_pulse[i] = TRASE_first_pulse(i,x,y)+
						TRASE_num_pulse(i,x,y);
	}
}

__host__  void TRASE_Params::set_read_start()
{
	for(int i=0; i<y;i++)
	{
		read_start[i] = TRASE_read_start(i,x,y);
	}
}

__host__  void TRASE_Params::set_read_end()
{
	for(int i=0; i<y;i++)
	{
		read_end[i] = TRASE_read_end(i,x,y);
	}
}



//calculation function
__host__ int TRASE_Params::TRASE_first_pulse(int seg, int res_x, int res_y) {
	int total_pulse = 0;
	int accumulation = 0;

	if(seg <(int)(res_x/2)){
		for(int i=0; i <= seg;i++){

			total_pulse += 3+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}
		total_pulse -=3+(2*(int)(res_y/2))+(accumulation-2);
		return total_pulse;



	}else if (seg>=(int)(res_x/2)&& seg <res_x-1){
		for(int i=0; i < (int)(res_x/2);i++){

			total_pulse += 3+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}


		accumulation=0;

		for(int i=(int)(res_x/2); i <= seg;i++){

			total_pulse += 2+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}

		total_pulse -=2+(2*(int)(res_y/2))+(accumulation-2);
		return total_pulse;


	}else if (seg == res_x-1){
	for(int i=0; i < (int)(res_x/2);i++){

		total_pulse += 3+(2*(int)(res_y/2))+accumulation;

		accumulation += 2;
	}

	accumulation=0;

	for(int i=0; i < (res_x)-1-(int)(res_x/2);i++){

		total_pulse += 2+(2*(int)(res_y/2))+accumulation;

		accumulation += 2;
	}
		return total_pulse;

	}else{
		printf("incorrect seg!\n");
		return 0;
	}
}


__host__ int TRASE_Params::TRASE_num_pulse(int seg, int res_x, int res_y){
	if(seg <(int)(res_x/2)){
		return 3+(2*(int)(res_y/2))+2*(seg);
	}else if (seg>=(int)(res_x/2)&& seg <res_x-1){

		return 2+(2*(int)(res_y/2))+2*(seg - (int)(res_x/2));


	}else if (seg == res_x-1){

		return 2+(2*(int)(res_y/2));

	}else{
		printf("incorrect seg!\n");
		return 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
__host__ int TRASE_Params::TRASE_read_start(int seg, int res_x, int res_y){

	int total_pulse = 0;
	int accumulation = 0;

	if(seg <(int)(res_x/2)){
		for(int i=0; i <= seg;i++){

			total_pulse += 3+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}
		total_pulse -=1+(2*(int)(res_y/2))+1;
		return total_pulse;



	}else if (seg>=(int)(res_x/2)&& seg <res_x-1){
		for(int i=0; i < (int)(res_x/2);i++){

			total_pulse += 3+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}


		accumulation=0;

		for(int i=(int)(res_x/2); i <= seg;i++){

			total_pulse += 2+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}

		total_pulse -=(2*(int)(res_y/2));
		return total_pulse;


	}else if (seg == res_x-1){
	for(int i=0; i < (int)(res_x/2);i++){

		total_pulse += 3+(2*(int)(res_y/2))+accumulation;

		accumulation += 2;
	}

	accumulation=0;

	for(int i=0; i < (res_x)-1-(int)(res_x/2);i++){

		total_pulse += 2+(2*(int)(res_y/2))+accumulation;

		accumulation += 2;
	}

	total_pulse += 1;
		return total_pulse;

	}else{
		printf("incorrect seg!\n");
		return 0;
	}
}


__host__ int TRASE_Params::TRASE_read_end(int seg, int res_x, int res_y){
	int total_pulse = 0;
	int accumulation = 0;

	if(seg <(int)(res_x/2)){
		for(int i=0; i <= seg;i++){

			total_pulse += 3+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}
		return total_pulse-1;



	}else if (seg>=(int)(res_x/2)&& seg <res_x-1){
		for(int i=0; i < (int)(res_x/2);i++){

			total_pulse += 3+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}

		accumulation=0;

		for(int i=(int)(res_x/2); i <= seg;i++){

			total_pulse += 2+(2*(int)(res_y/2))+accumulation;

			accumulation += 2;
		}
		return total_pulse-1;


	}else if (seg == res_x-1){
	for(int i=0; i < (int)(res_x/2);i++){

		total_pulse += 3+(2*(int)(res_y/2))+accumulation;

		accumulation += 2;
	}

	accumulation=0;

	for(int i=0; i < (res_x)-1-(int)(res_x/2);i++){

		total_pulse += 2+(2*(int)(res_y/2))+accumulation;

		accumulation += 2;
	}

	total_pulse += 2+(2*(int)(res_y/2));
		return total_pulse-1;

	}else{
		printf("incorrect seg!\n");
		return 0;
	}
}




__host__ void TRASE_Params::Echo_train(SimuParams* par){




	int array_index = 0;
	real initial_time = 0.0;

	int onedex = 2;
	int num_ratio = 0;

	for(int num_TR = 0; num_TR<(int)(par->res_x/2);num_TR++)
	{
		onedex = 2;

		pulse_switch[0+num_ratio] = 0;

		pulse_switch[1+num_ratio] = 3;
		for(int i =0; i < num_TR; i++)
		{
			pulse_switch[onedex+num_ratio] = 1;
			pulse_switch[onedex+1+num_ratio] = 3;

			onedex+=2;
		}

		for(int i =0; i < (int)(par->res_y/2); i++)
		{
			pulse_switch[onedex+num_ratio] = 1;
			pulse_switch[onedex+1+num_ratio] = 2;
			onedex+=2;
		}
		pulse_switch[onedex+num_ratio] = 1;

		num_ratio +=(2+(num_TR*2)+((int)(par->res_y/2))*2)+1;
	}



//A-C-(AC)-(BA)-A
	for(int num_TR = 0; num_TR < (par->res_x)-1-(int)(par->res_x/2);num_TR++)
	{
		onedex = 2;
		pulse_switch[0+num_ratio] = 0;
		pulse_switch[1+num_ratio] = 3;
		for(int i =0; i < num_TR; i++)
		{
			pulse_switch[onedex+num_ratio] = 1;
			pulse_switch[onedex+1+num_ratio] =  3;
			onedex+=2;
		}
		for(int i =0; i < (int)(par->res_y/2); i++)
		{
			pulse_switch[onedex+num_ratio] = 2;
			pulse_switch[onedex+1+num_ratio] = 1;
			onedex+=2;
		}

		num_ratio +=(2+(num_TR*2)+((int)(par->res_y/2))*2);
	}

//k-space center
	onedex = 1;
	pulse_switch[0+num_ratio] = 0;

	for(int i =0; i < (int)(par->res_y/2); i++)
	{
		if (i==0){
			pulse_switch[onedex+num_ratio] = 1;

			pulse_switch[onedex+1+num_ratio] = 2;

			onedex +=2;
		}else{
			pulse_switch[onedex+num_ratio] = 1;

			pulse_switch[onedex+1+num_ratio] = 2;
			onedex +=2;
		}
	}
	pulse_switch[onedex+num_ratio] = 1;
/*
	printf("The TRASE_total is %d, and the pulse_switch has %d\n",par->TRASE_total,onedex+num_ratio);


	for(int i=0;i<par->TRASE_total;i++){

		printf("%d\n",pulse_switch[i]);
	}
*/
}

