/**
* Name: TransportTrip
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportTrip

import "../Vehicles/Bus.gaml"

import "../../World.gaml"

import "TransportStop.gaml"

/* Insert your model definition here */

species TransportTrip skills: [scheduling] schedules: [] {
	string route_id;
	string route_long_name;
	string service_id;
	int trip_id;
	int direction_id;
	int shape_id;
	int route_type;
	
	//the itinerary
	list<TransportStop> stops;
	list<date> departure_times;
	
	action schedule_departure_time {
		assert length(stops) = length(departure_times);
		if !empty(departure_times) {
			do later the_action:"start_trip" at:departure_times[0];
		}else{
			write "TransportTrip: " + route_id + " for " + route_long_name + " has no planned itinerary! It wont start." color:#red;
		}
	}
	
	action start_trip {
		create Bus {
			trip <- myself;
			location <- trip.stops[0].location;
			do take_passengers_in;
			do goto(trip.stops[1].location);
		}
	}
	
	action add_stop(string departure_str, TransportStop ts){
		date d <- convert(departure_str);
		
		//add all elements, all list should have the same length !
		add d to: departure_times;
		add ts to: stops;
	}
	
	date convert(string s){
		list<string> s_split <- s split_with(':');
		int h <- int(s_split[0]);
//		int m <- int(s_split[1]);
//		int s <- int(s_split[2]);
		
		if h > 23 {
			h <- h - 24;
		}
		
//		write s;
		
		return date([1970, 1, 1, h, int(s_split[1]), 0]);
	}
}