/**
* Name: TxtLog
* Based on the internal empty template. 
* Author: flavi
* Tags: 
*/


model TxtLog

/**
* Name: consolLog
* Based on the internal empty template. 
* Author: flavi
* Tags: 
*/

import "Logger.gaml"


global{

}

species CSVLog parent:Logger{
	string log_file;
	map<int,map<string,float>> logged;
	
	init{
		log_file <- "Log.csv";
	}
	
	action save_log(string mess){
		save logged to:log_file format:csv rewrite:true;
	}
	
	action log(string mess){
		add mess to:logged;
	}
	
	action log_csv(int i, string s, float value){
		add value to:logged;
	}
}


