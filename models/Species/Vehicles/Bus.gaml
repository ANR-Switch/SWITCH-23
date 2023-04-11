/**
* Name: Bus
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

/*
 * Use this model to add new types of vehicles
 */

model Bus

import "../Map/TransportTrip.gaml"

import "Vehicle.gaml"

species Bus parent: Vehicle schedules: [] {
	rgb parking_color <- rgb([125, 92, 103]);
	rgb driving_color <- #pink;
	TransportTrip trip;
	int current_stop_idx <- 0;
	
	init {
		color <- parking_color;
	}
	
	action init_vehicle(Person _owner, float _length<-10.0#meter, float _speed<-90#km/#h, int _seats<-40){
		//_owner is to match the other vehicle classes, but a common transport doesnot need one
		length <- _length;
		speed <- _speed;
		seats <- _seats;	
	}
	
	action go_to_next_stop {
		current_stop_idx <- current_stop_idx + 1;
		
		if current_stop_idx < length(trip.stops){
			my_path <- compute_path_between(location, trip.stops[current_stop_idx].location);
		
			if my_path = nil {
				write get_current_date() + ": " + name + " for: " + trip.route_long_name +" is not able to find a path between " + trip.stops[current_stop_idx-1] + " and " + trip.stops[current_stop_idx] color: #red;
			}else{
				if !empty(my_path.edges) {
					do propose;			
				}else{
					write get_current_date() + ": " + name + " but the path computed is null.";
				}	
			}
		}else{
			//we are in terminus
		}
	}
	
	path compute_path_between(point p1, point p2) {
		return path_between(car_road_graph, p1, p2);
	}
	
	action take_passengers_in {
		list<Person> new_passengers;
		ask trip.stops[current_stop_idx] {
			new_passengers <- get_waiting_persons(myself);
		}
		
		loop p over: new_passengers {
			do add_passenger(p);
		}
	}
	
	action goto(point dest){
		//init
		current_road <- nil;
		my_destination <- dest;
		my_path <- compute_path_between(location, my_destination);

		if my_path = nil {
			write get_current_date() + ": " + name + " for: " + trip.route_long_name +" is not able to find a path between " + location + " and " + dest color: #red;
		}else{
			if !empty(my_path.edges) {
				do propose;			
			}else{
				write get_current_date() + ": " + name + " but the path computed is null.";
			}	
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
	}
	
	aspect default {
		draw circle(10) color: color border: #black;
	}
}

