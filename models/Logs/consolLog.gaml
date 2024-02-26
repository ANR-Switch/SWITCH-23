/**
* Name: consolLog
* Based on the internal empty template. 
* Author: flavien
* Tags: 
*/


model consolLog

import "Logger.gaml"


global{

}

species ConsolLog parent:Logger{	
	
	action log(string mess){
		if mess='end_of_simulation_logs'{
			if countForcing{
		 		write "road get forced :"+forcing+" times" color:#yellow;
		 	}
		 	if countPath{
		 		write ""+ pathNotFound+" path as not been found" color:#yellow;
		 	}
		 	if countDayEnded{
		 		write ""+ (length(Person)- dayEnded)+" people didn't end their travel within a day." color:#yellow;
		 	}
		 	if countTrajet{
		 		write ""+nb_trajet+" trajet on été effectué durant la simulation" color:#yellow;
		 	}
		 	
		}
		else{
			write mess;
		}
		
	}
	
	action write_counter{
		
	}
}
