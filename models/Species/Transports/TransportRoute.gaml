/**
* Name: TransportRoute
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportRoute

species TransportRoute schedules: [] {
	string route_id;
	string short_name;
	string long_name;
	int type;
	
	rgb color <- #pink;
	
	aspect default {
		draw shape color:color;
	}
}

