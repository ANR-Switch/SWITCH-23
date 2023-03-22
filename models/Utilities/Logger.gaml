/**
* Name: Logger
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Logger

import "../Species/Person.gaml"

/* observer */

species Logger {
	bool road_b <- true;
	
	action log_roads(bool b){
		if (b) {
			
			
			
		}else{
			return;
		}
	}
	
	action final_log {
		write "\n " + Person count(each.is_going_in_ext_zone) + " persons went out of the simulated city to work.";
	}
	
	reflex log {
		do log_roads(road_b);
	}
}