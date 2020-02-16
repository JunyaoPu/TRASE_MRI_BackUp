#include "Update_Mag.cuh"



__device__ void Update_Mag(real &Mx,
		real &My,
		real &Mz,
		real w,
		real time,
		real time_step,
		real strength90,
		real strength180,
		real dg,
		Vector3 B0,
		Vector3 r,
		int pulse_pick,
		real T1,
		real T2
		){
		Vector3 TRASE_M,k1,k2,k3,k4,finaldM;
		Vector3 v1,v2,v3;
		Vector3 G;
		real pulse_strength;


		TRASE_M.x = Mx;
		TRASE_M.y = My;
		TRASE_M.z = Mz;

		real trig_num1=w*time;
		real trig_num2=w*(time + .5*time_step);
		real trig_num3=w*(time + time_step);
















//here is doing	(*C)->getField(*B, r, tn)+B0

		if(pulse_pick==0){			//Exciting pulse

			pulse_strength =2*strength90*cos(trig_num1)*0.995;
			v1=Vector3(pulse_strength, 0, 0)+B0;

			pulse_strength =2*strength90*cos(trig_num2)*0.995;
			v2=Vector3(pulse_strength, 0, 0)+B0;

			pulse_strength =2*strength90*cos(trig_num3)*0.995;
			v3=Vector3(pulse_strength, 0, 0)+B0;


		}else if(pulse_pick == 1){		//refocusing pulse with no phase


			pulse_strength =2*strength180*cos(trig_num1)*0.995;
			G=Vector3(0, pulse_strength, 0);
			v1=G+B0;

			pulse_strength =2*strength180*cos(trig_num2)*0.995;
			G=Vector3(0, pulse_strength, 0);
			v2=G+B0;

			pulse_strength =2*strength180*cos(trig_num3)*0.995;
			G=Vector3(0, pulse_strength, 0);
			v3=G+B0;


			/*
		if(pulse_pick==0){			//Exciting pulse

			pulse_strength =2*strength90*cos(trig_num1)*0.995;
			v1=Vector3(strength90*cos(w*time), -strength90*sin(w*time), 0)+B0;
			pulse_strength =2*strength90*cos(trig_num2)*0.995;
			v2=Vector3(strength90*cos(w*time), -strength90*sin(w*time), 0)+B0;
			pulse_strength =2*strength90*cos(trig_num3)*0.995;
			v3=Vector3(strength90*cos(w*time), -strength90*sin(w*time), 0)+B0;


		}else if(pulse_pick == 1){		//refocusing pulse with no phase


			pulse_strength =2*strength180*cos(trig_num1)*0.995;
			G=Vector3(-strength180*cos(w*time+PI/2), strength180*sin(w*time+PI/2), 0);
			v1=G+B0;

			pulse_strength =2*strength180*cos(trig_num2)*0.995;
			G=Vector3(-strength180*cos(w*time+PI/2), strength180*sin(w*time+PI/2), 0);
			v2=G+B0;

			pulse_strength =2*strength180*cos(trig_num3)*0.995;
			G=Vector3(-strength180*cos(w*time+PI/2), strength180*sin(w*time+PI/2), 0);
			v3=G+B0;
			*/



		}else if(pulse_pick ==2){		//refocusing pulse with X phase

			real pulse_X= (dg)*(r.x);

			pulse_strength =2*strength180*cos(trig_num1)*0.995;
			G=Vector3(pulse_strength*sin(pulse_X), pulse_strength*cos(pulse_X), 0);
			v1=G+B0;

			pulse_strength =2*strength180*cos(trig_num2)*0.995;
			G=Vector3(pulse_strength*sin(pulse_X), pulse_strength*cos(pulse_X), 0);
			v2=G+B0;

			pulse_strength =2*strength180*cos(trig_num3)*0.995;
			G=Vector3(pulse_strength*sin(pulse_X), pulse_strength*cos(pulse_X), 0);
			v3=G+B0;

		}else{	//refocusing pulse with Y phase				//here reduced 4s for the simulator
			real pulse_Y=(dg)*(r.y);

			pulse_strength =2*strength180*cos(trig_num1)*0.995;
			G=Vector3(pulse_strength*sin(pulse_Y), pulse_strength*cos(pulse_Y), 0);
			v1=G+B0;

			pulse_strength =2*strength180*cos(trig_num2)*0.995;
			G=Vector3(pulse_strength*sin(pulse_Y), pulse_strength*cos(pulse_Y), 0);
			v2=G+B0;

			pulse_strength =2*strength180*cos(trig_num3)*0.995;
			G=Vector3(pulse_strength*sin(pulse_Y), pulse_strength*cos(pulse_Y), 0);
			v3=G+B0;
		}








//no relaxation
		/*
		k1=(TRASE_M % v1 )*GAMMA*time_step;
		k2 = ((TRASE_M + k1*.5)% v2 )*GAMMA*time_step;
		k3 = ((TRASE_M + k2*.5)% v2)*GAMMA*time_step;
		k4 = ((TRASE_M + k3)%v3 )*GAMMA*time_step;
		*/




//with relaxation
		k1=(((TRASE_M % v1 )*GAMMA)- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;
		k2 = ((((TRASE_M + k1*.5)% v2 )*GAMMA)- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;
		k3 = ((((TRASE_M + k2*.5)% v2)*GAMMA)- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;
		k4 = ((((TRASE_M + k3)%v3 )*GAMMA)- Vector3(Mx / T2, My / T2, (Mz - 1.0) / T1))*time_step;


		finaldM = (k1 + k2*2.0 + k3*2.0 + k4)*(1.0 / 6.0);
		Mx += finaldM.x;
		My += finaldM.y;
		Mz += finaldM.z;

}











__device__ Vector3 pulse_Exc(real strength, real trig_num){
	//tip on + x-axis(apply on  -y-axis)
	return Vector3(-strength*sin(trig_num), -strength*cos(trig_num), 0);

}

__device__ Vector3 pulse_ref(real strength, real trig_num){

	//apply on  +x-axis
	return Vector3(strength*cos(trig_num), -strength*sin(trig_num), 0);
}

__device__ Vector3 pulse_axis(real strength, real trig_num, real axis){
	real cos_angle = cos(trig_num);
	real sin_angle = sin(trig_num);

	real cos_gz = cos(axis);
	real sin_gz = sin(axis);

	//on +x axis
	real x_field = cos_angle*strength*cos_gz + sin_angle*strength*sin_gz;
	real y_field = -sin_angle*strength*cos_gz + cos_angle*strength*sin_gz;

	return Vector3(x_field, y_field, 0);



}



