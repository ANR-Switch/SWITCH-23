/**
* Name: TransportEdge
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
* 
* 
* 
* This species is only for the public transport graph
*/

model TransportEdge

import "TransportStop.gaml"

species TransportEdge schedules: [] {
	TransportStop source;
	TransportStop target;
	TransportTrip trip;
	bool connection <- false;
	bool walk_trip <- false;
	float connection_weight <- Constants[0].connection_weight;
	date target_arrival_date;
	date source_arrival_date;
	float weight;
	
	int route_type;
	
//	action compute_weight {
//		if !connection {
//			weight <- distance_to(source.location, target.location);
//		}
//	}
	
	aspect default {
		/*
		 * not to be used, only for debug
		 */
		draw shape color:#cyan;
	}
}
