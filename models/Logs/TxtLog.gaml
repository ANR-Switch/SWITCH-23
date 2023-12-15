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

species TxtLog parent:Logger{
	string log_file;
	
	init{
	log_file <- "Log.txt";
	save 'start new simulation' to:log_file format:text;
	}
	
	action save_log(string mess){
		save mess to:log_file format:text rewrite:false;
	}
	
	action log(string mess){
		if mess='end_of_simulation_logs'{
		 		do save_log ("road get forced :"+forcing+" times");
		 		do save_log (""+ pathNotFound+" path as not been found") ;
		 		do save_log (""+ (length(Person)- dayEnded)+" people didn't end their travel within a day." );
		}
		else{
			do save_log(mess)  ;
		}
		
	}
	
	action write_counter{
		
	}
}


