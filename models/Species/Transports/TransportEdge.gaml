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
	date arrival_date;
	
	int route_type;
	
	aspect default {
		draw shape color:#cyan;
	}
}
