/**
* Name: TransportTrip
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportTrip

import "../Vehicles/Tramway.gaml"

import "../Vehicles/Teleo.gaml"

import "../Vehicles/Metro.gaml"

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
	
	
	int registration_minutes <- 30 const: true;
	
	//the itinerary
	list<TransportStop> stops;
	list<date> departure_times;
	
	list<TransportEdge> my_edges;
	
	action schedule_departure_time {		
		assert length(stops) = length(departure_times);
		if !empty(departure_times) {
			//register to graph a bit before our departure fro graph search
			if get_current_date() < departure_times[0] add_minutes - registration_minutes {
				do later the_action:"register_to_graph" at: departure_times[0] add_minutes - registration_minutes;
			}else{
				do later the_action:"register_to_graph" at: get_current_date() add_seconds 1;
			}
			
			
			//departure!
			do later the_action:"start_trip" at:departure_times[0];
		}else{
			write "TransportTrip: " + route_id + " for " + transport_route.long_name + " has no planned itinerary! It wont start." color:#red;
		}
	}
	
	action register_to_graph {
		loop i from:0 to: length(stops) - 2 {
			create TransportEdge returns: TE {
				source <- myself.stops[i];
				target <- myself.stops[i+1];
				shape <- polyline([source.location, target.location]); //useful?
				trip <- myself;
				route_type <- myself.transport_route.type;
				arrival_date <- myself.departure_times[i+1];
			}
			add TE[0] to: my_edges;
		}
	}
	
	action start_trip {
		switch transport_route.type {
			match 3 {
				create Bus {
					event_manager <- myself.event_manager;
					trip <- myself;
					location <- trip.stops[0].location;
					driving_color <- myself.transport_route.color;
					do init_vehicle(Person[0]);
					
//					write get_current_date() + ": " + myself.transport_route.long_name + " starts a trip with: " + name color:driving_color;
					
					do take_passengers_in;
					do go_to_next_stop;
				} 
			}
			
			match 1 {
				create Metro {
					event_manager <- myself.event_manager;
					trip <- myself;
					location <- trip.stops[0].location;
					color <- myself.transport_route.color;
					
//					write get_current_date() + ": " + myself.transport_route.long_name + " starts a trip with: " + name color:color;
					
					do take_passengers_in;
					do go_to_next_stop;
				} 
			}
			
			match 0 {
				create Tramway {
					event_manager <- myself.event_manager;
					trip <- myself;
					location <- trip.stops[0].location;
					color <- myself.transport_route.color;
					
//					write get_current_date() + ": " + myself.transport_route.long_name + " starts a trip with: " + name color:color;
					
					do take_passengers_in;
					do go_to_next_stop;
				}
			}
			
			match 6 {
				create Teleo {
					event_manager <- myself.event_manager;
					trip <- myself;
					location <- trip.stops[0].location;
					color <- myself.transport_route.color;
					
//					write get_current_date() + ": " + myself.transport_route.long_name + " starts a trip with: " + name color:color;
					
					do take_passengers_in;
					do go_to_next_stop;
				} 
			}
			
			default {
				write "Unknown common transport type: " + transport_route.type + " for trip: " + trip_id + transport_route.long_name;
			}
		}
		
	}
	
	action end_trip {		
		ask my_edges {
			do die;
		}
		do die;
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