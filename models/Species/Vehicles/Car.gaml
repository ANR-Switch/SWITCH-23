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

import "Vehicle.gaml"

species Car parent: Vehicle schedules: [] {
	rgb parking_color <- rgb([165, 165, 0]);
	rgb driving_color <- #yellow;
	
	init {
		color <- parking_color;
	}
	
	action init_vehicle(Person _owner, float _length<-4.0#meter, float _speed<-130#km/#h, int _seats<-4){
		owner <- _owner;
//		do add_passenger(owner);
		length <- _length;
		speed <- _speed;
		seats <- _seats;
		add self to: owner.vehicles;
//		owner.current_vehicle <- self;		
		
		//set location
//		location <- _owner.location; //simple way
		list<Road> car_road_subset <- Road where (each.car_track);
		Road closest_road <- car_road_subset closest_to(owner.location);
		list<point> l <- closest_road.displayed_shape closest_points_with (owner.location); 
		location <- l[0];
	}
	
	path compute_path_between(point p1, point p2) {
		return path_between(car_road_graph, p1, p2);
	}
	
	action goto(point dest){
		past_roads <- [];
		if !empty(passengers) {
			//init
			current_road <- nil;
			owner.location <- location;
			my_destination <- dest;
//			float t1 <- machine_time;
			my_path <- compute_path_between(location, my_destination);
//			write "time : >>> " + (machine_time - t1) + " milliseconds" color: #green;
			if my_path = nil {
				write get_current_date() + ": " + name + " belonging to: " + owner.name +" is not able to find a path between " + owner.current_building + " and " + owner.next_building color: #red;
				write "The motion will not be done. \n The activity: " + owner.current_activity.title + " of: " + owner.name + " might be done in the wrong location." color: #orange;
				owner.location <- any_location_in(owner.current_activity.activity_location);
				owner.skipped_travels <- owner.skipped_travels + 1;
				add [] to: owner.past_paths;
				ask owner {
					do end_motion;
				}
			}else{
				if !empty(my_path.edges) {
					//compute theoretical arrival date for comparaison at the end of the simulated day
					theoretical_arrival_date <- get_current_date() add_seconds compute_theoretical_time();
					owner.theoretical_travel_duration <- compute_theoretical_time();
					
					do propose;
			
				}else{
					write get_current_date() + ": " + owner.name + " called goto on " + name + " but the path computed is null.";
				}	
			}
		}else{
			write get_current_date() + ": " + name + " is asked to go somewhere without a driver !" color: #red;
		}
	}
	
	action propose {
		//this method is similar to the propose done by roads. It should be used only at the init of the motion
		Road r <- Road(my_path.edges[0]);
		ask r {
			do treat_proposition(myself);
		}
	}
	
	action enter_road(Road road){
		//log
		if current_road != nil {
			//here we register previous road info in the log
			float t;
			ask current_road {
				t <- get_theoretical_travel_time(myself);
			}
			int road_lateness <- int((get_current_date() - log_entry_date) - t);
			do log(road_lateness);
		}
		log_entry_date <- get_current_date();
		//
		
		color <- driving_color;
		current_road <- road;
		do move_to(road.location);
			
		add Road(my_path.edges[0]) to: past_roads; //to remove
		remove index: 0 from: my_path.edges;
	}
	
	action arrive_at_destination {		
		//delete from previous road
		if current_road != nil {
			//log
			float t;
			ask current_road {
				t <- get_theoretical_travel_time(myself);
			}
			int road_lateness <- int((get_current_date() - log_entry_date) - t);
			do log(road_lateness);
			//
			
			list<point> p <- current_road.displayed_shape closest_points_with(owner.current_destination);
			do move_to(p[0]);
			ask current_road {
				bool found <- remove(myself);	
				assert found warning: true;
			}	
		}else{
			write get_current_date() + ": Something is wrong with " + name + "\n Belonging to " + owner.name color:#orange;
		}
		color <- parking_color;
		current_road <- nil;
//		owner.location <- my_destination;
		
		//compute lateness for chart display
		float _lateness <- (get_current_date() - theoretical_arrival_date);
		assert _lateness >= 0;
		if _lateness > 0 {
			owner.lateness <- _lateness;
		}else if _lateness = 0 {
			owner.lateness <- 0.0;
		}else{
			write "Lateness is negative, this should not happen." color:#red;
		}
		
		add past_roads to: owner.past_paths;
		ask owner {
			do walk_to(current_destination); //this may kill the vehicle so make sure this is our last action
		}
	}
	
	float compute_theoretical_time {
		float t;
		loop r over: my_path.edges {
			ask Road(r) {
				t <- t + get_theoretical_travel_time(myself);
			}
		}
		return t;
	} 
	
	aspect default {
		draw circle(7) color: color border: #black;
	}
}

