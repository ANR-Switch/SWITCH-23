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
	string service_id;
	int trip_id;
	int direction_id;
	int shape_id;
	TransportRoute transport_route;
	
	bool available <- false;
	
	//the itinerary
	list<TransportStop> stops;
	list<date> departure_times;
	
	action schedule_departure_time {
		assert length(stops) = length(departure_times);
		if !empty(departure_times) {
			do later the_action:"start_trip" at:departure_times[0];
		}else{
			write "TransportTrip: " + route_id + " for " + transport_route.long_name + " has no planned itinerary! It wont start." color:#red;
		}
	}
	
	action start_trip {
		available <- true;
		switch transport_route.type {
			match 3 {
				create Bus {
					event_manager <- myself.event_manager;
					trip <- myself;
					location <- trip.stops[0].location;
					driving_color <- myself.transport_route.color;
					do init_vehicle(Person[0]);
					
					write get_current_date() + ": " + myself.transport_route.long_name + " starts a trip with: " + name color:#pink;
					
					do take_passengers_in;
					do go_to_next_stop;
				} 
			}
			
			match 1 {
				
			}
			
			match 0 {
				
			}
			
			match 6 {
				
			}
			
			default {
				write "Unknown common transport type: " + transport_route.type + " for trip: " + trip_id + transport_route.long_name;
			}
		}
		
	}
	
	action add_stop(string departure_str, TransportStop ts){
		if(departure_str != nil and ts != nil){
			date d <- convert(departure_str);
			
			//add all elements, all list should have the same length !
			add d to: departure_times;
			add ts to: stops;	
		}else if departure_str = nil and ts = nil{
			write string(trip_id) + ": Both the " + length(stops) + "th departure time and TransportStop of " + route_id + " have a problem: " + departure_str + " and " + ts;
		}else if departure_str = nil {
			write string(trip_id) + ": the " + length(stops) + "th departure time of " + route_id + " has a problem: " + departure_str;
		}else if ts = nil {
			write string(trip_id) + ": the " + length(stops) + "th TransportStop of " + route_id + " has a problem: " + ts;			
		}
	}
	
	date convert(string s){
		list<string> s_split <- s split_with(':');
		int d <- starting_date.day;
		int h <- int(s_split[0]);
//		int m <- int(s_split[1]);
//		int s <- int(s_split[2]);
		
		if h > 23 {
			h <- h - 24;
			d <- d + 1;
		}
				
		return date([1970, 1, d, h, int(s_split[1]), 0]);
	}
}