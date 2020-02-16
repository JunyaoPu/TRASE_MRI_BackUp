#include "recorder.h"



recorder::recorder(string exp_name){
	_exp_name = exp_name;
}

string recorder::make_name(string ext){
	string name;
	time_t rawtime;
	struct tm * timeinfo;
	char buffer[80];
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime(buffer, 80, " %Y_%j_%H_%M_%S", timeinfo);
	string time_str(buffer);




	name = DIR_REC + _exp_name + time_str + ext;				//make a name and retuen it back


//	cout<<name<<endl;


	return name;
}

bool already_exists(string file_name){
	ifstream attempt(file_name);
	return attempt.good();
}

ofstream recorder::setup_record_csv(){
	string file_name = make_name(".csv");
	int t_dup = 0;

	while (already_exists(file_name)){
		t_dup++;
		file_name = make_name("_" + std::to_string(t_dup) + ".csv");
	}

	ofstream trial(file_name);

	return trial;
}

ofstream recorder::setup_record_image(){
	string file_name = make_name(".pgm");					//make a file_name      the make_name is called		//return a name
	int t_dup = 0;

	while (already_exists(file_name)){						//check if the file name exist
		t_dup++;
		file_name = make_name("_" + std::to_string(t_dup) + ".pgm");		//if it is exist, make other name
	}

	ofstream trial(file_name);											//make trial as ofstream type and return it

	return trial;
}

