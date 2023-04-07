/**
* Name: TransportTrip
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportTrip

import "../../World.gaml"

import "TransportStop.gaml"

/* Insert your model definition here */

species TransportTrip schedules: [] {
	string route_id;
	string route_long_name;
	string service_id;
	int trip_id;
	int direction_id;
	int shape_id;
	
	list<TransportStop> stops;
	list<date> departure_times;
	
	action add_stop(string departure_str, TransportStop ts){
		date d <- convert(departure_str);
		
		//add all elements, all list should have the same length !
		add d to: departure_times;
		add ts to: stops;
	}
	
	date convert(string s){
		date d <- sim_starting_date;
		list<string> s_split <- s split_with(':');
//		d.hour <- int(s_split[0]);
//		d.minute <- int(s_split[1]);
//		d.second <- int(s_split[2]);
		return d;
	}
}