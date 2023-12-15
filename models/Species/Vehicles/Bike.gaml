/**
* Name: Car
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

/*
 * Use this model to add new types of vehicles
 */

model Bike

import "../../Utilities/Constants.gaml"

import "Vehicle.gaml"


species Bike parent: Vehicle schedules: [] {
	
	init {
		color <- #limegreen;
	}
	
	action init_vehicle(Person _owner, Logger l){
		log <- l;
		my_graph <- feet_road_graph;
		owner <- _owner;
//		do add_passenger(owner);
		location <- _owner.location;
		length <- 0.0#meter;
		speed <- 22#km/#h;
		seats <- 1;
		event_manager <- owner.event_manager;
		add self to: owner.vehicles;
//		owner.current_vehicle <- self;
	}
	
	
	
	
}

