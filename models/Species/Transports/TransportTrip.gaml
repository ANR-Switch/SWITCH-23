/**
* Name: TransportTrip
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportTrip

import "TransportEdge.gaml"

import "TransportRoute.gaml"

import "../Vehicles/Tramway.gaml"

import "../Vehicles/Teleo.gaml"

import "../Vehicles/Metro.gaml"

import "../Vehicles/Bus.gaml"

//import "../../World.gaml"

/* Insert your model definition here */

species TransportTrip skills: [scheduling] schedules: [] {
	string route_id;
	string service_id;
	int trip_id;
	int direction_id;
	int shape_id;
	TransportRoute transport_route;
	bool alive <- true;
	//only useful for bus
	list<list<Road>> bus_path;
	
	
	int registration_minutes <- Constants[0].minutes_for_graph_registration;
	
	//the itinerary
	list<TransportStop> stops;
	list<date> departure_times;
	
	list<TransportEdge> my_edges;
	
	action schedule_departure_time {		
		assert length(stops) = length(departure_times);
		if !empty(departure_times) {
			if Constants[0].dynamic_public_transport_graph {
				//register to graph a bit before our departure fro graph search
				if get_current_date() < departure_times[0] add_minutes - registration_minutes {
					do later the_action:"register_to_graph_2" at: departure_times[0] add_minutes - registration_minutes;
				}else{
					write 'A trnsportTrip register itself late on schedule, this should not happen' color:#red;
					do later the_action:"register_to_graph_2" at: get_current_date() add_seconds 1;
				}
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
				shape <- polyline([source.location, target.location]); //useful for directed graph?
				trip <- myself;
				route_type <- myself.transport_route.type;
				source_arrival_date <- myself.departure_times[i];
				target_arrival_date <- myself.departure_times[i+1];
				weight <- target_arrival_date - source_arrival_date;
			}
			add TE[0] to: my_edges;
		}
	}
	
	action register_to_graph_2 {
		/*
		 * Dans cette version de la méthode de création de graphe, nous ajoutons plus de 
		 * edges au graphe de sorte à minimiser les changements inutiles entre les lignes
		 */
		if Constants[0].dynamic_public_transport_graph {
			write "Il est fortement recommandé de na pas utiliser cette methode avec le graphe dynamique car cela prend beaucoup trop de temps!" color:#red;
		}
		 
		loop edge_length from: 1 to: length(stops) {
			loop decalage_idx from: 0 to: edge_length - 1 {
				loop i from: 0 to: length(stops) - 2 {
					if i+decalage_idx+edge_length < length(stops) {
						create TransportEdge returns: TE {
							source <- myself.stops[i+decalage_idx];
							target <- myself.stops[i+decalage_idx+edge_length];
							shape <- polyline([source.location, target.location]); //useful for directed graph?
							trip <- myself;
							route_type <- myself.transport_route.type;
							source_arrival_date <- myself.departure_times[i];
							target_arrival_date <- myself.departure_times[i+edge_length];
							weight <- (target_arrival_date - source_arrival_date) + Constants[0].connection_penalty;
						}
						add TE[0] to: my_edges;	
					}
				}	
			}	
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
					route <- myself.transport_route.long_name;
					
					do init_vehicle(Person[0]); //?
										
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
		if Constants[0].dynamic_public_transport_graph {		
			ask my_edges {
				do die;
			}
			alive <- false;
			do die;	
		}else{
			alive <- false;
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
				
		return date([starting_date.year, starting_date.month, d, h, int(s_split[1]), 0]);
	}
}