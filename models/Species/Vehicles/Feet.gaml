/**
* Name: Car
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

/*
 * Use this model to add new types of vehicles
 */

model Feet

import "../Map/Road.gaml"

import "Vehicle.gaml"


species Feet parent: Vehicle schedules: [] {
	

	init {
		my_graph <- feet_road_graph;
		color <- #darkgoldenrod;
	}
	
	action init_vehicle(Person _owner, Logger l){
		log <- l;
		owner <- _owner;
//		do add_passenger(owner);
		location <- _owner.location;
		length <- 0.0#meter;
		speed <- 5#km/#h;
		seats <- 1;
		event_manager <- owner.event_manager;
		add self to: owner.vehicles;
//		owner.current_vehicle <- self;
	}
	
	
	
//	float compute_theoretical_time {
//		float t;
//		loop r over: my_path.edges {
//			ask Road(r) {
//				t <- t + get_theoretical_travel_time(myself);
//			}
//		}
//		return t;
//	} 
}

