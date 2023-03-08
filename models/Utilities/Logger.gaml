/**
* Name: Logger
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Logger

/* observer */

species Logger {
	bool road_b <- true;
	
	action log_roads(bool b){
		if (b) {
			
			
			
		}else{
			return;
		}
	}
	
	
	reflex log {
		do log_roads(road_b);
	}
}