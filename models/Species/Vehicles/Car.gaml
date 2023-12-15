/**
* Name: Car
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

/*
 * Use this model to add new types of vehicles
 */

model Car

import "../../Logs/consolLog.gaml"

import "Vehicle.gaml"


species Car parent: Vehicle schedules: [] {
	rgb parking_color <- rgb([165, 165, 0]);
	rgb driving_color <- #yellow;
	bool countPath;
	bool verboseCarPath;
	
	init {
		color <- parking_color;
	}
	
	action init_vehicle(Person _owner, Logger l){
		log <- l;
		my_graph <- car_road_graph;
		owner <- _owner;
//		do add_passenger(owner);
		length <- Constants[0].car_size #meter;
		speed <- 130#km/#h;
		seats <- 4;
		event_manager <- owner.event_manager;
		add self to: owner.vehicles;
//		owner.current_vehicle <- self;		
		
		//set location
		location <- _owner.location; //simple way
//		list<Road> car_road_subset <- Road where (each.car_track);
//		Road closest_road <- car_road_subset closest_to(owner.location);
//		list<point> l <- closest_road.displayed_shape closest_points_with (owner.location); 
//		location <- l[0];
	}
	

	
/* 	
	action trash_log {
		string output_path <- "C:\\Users\\coohauterv\\git\\SWITCH-23\\output\\";
		string the_file <- output_path + "failed_buildings.csv" ;
		save [owner.current_building.db_id, owner.next_building.db_id] to: the_file format:"csv" rewrite:false;
	
	}
*/	
	aspect default {
		draw circle(10) color: color border: #black;
	}
}

