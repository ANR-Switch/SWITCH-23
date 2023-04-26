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

import "../Transports/TransportTrip.gaml"

import "Vehicle.gaml"

species Bus parent: Vehicle schedules: [] {
	rgb parking_color <- #gray;
	rgb driving_color <- #pink;
	
	//bus
	TransportTrip trip;
	int current_stop_idx <- 0;
	string next_stop ; //useful for debug
	
	init {
		color <- parking_color;
	}
	
	action init_vehicle(Person _owner, float _length<-11.0#meter, float _speed<-90#km/#h, int _seats<-40){
		//_owner is to match the other vehicle classes, but a common transport doesnot need one
//		owner <- _owner; //random assignement, useless except to use get_current_date of Vehicle.gaml
		length <- _length;
		speed <- _speed;
		seats <- _seats;	
	}
	
	action go_to_next_stop {		
		current_stop_idx <- current_stop_idx + 1;
		
		if current_stop_idx < length(trip.stops){
			next_stop <- trip.stops[current_stop_idx].real_name;
			
			my_path <- compute_path_between(location, trip.stops[current_stop_idx].location);
		
			if my_path = nil {
				//TODO remettre les write
//				write get_current_date() + ": " + name + " for: " + trip.transport_route.long_name +" is not able to find a path between " + trip.stops[current_stop_idx-1] + " and " + trip.stops[current_stop_idx] color: #red;
				do go_to_next_stop;
			}else{
				if !empty(my_path.edges) {
					do propose;			
				}else{
					//this happens
//					write get_current_date() + ": " + name + " but the path computed is null.";
					do go_to_next_stop;
				}	
			}
		}else{
			//we are in terminus
			ask trip {
				do end_trip;
			}			
		}
	}
	
	path compute_path_between(point p1, point p2) {
		return path_between(car_road_graph, p1, p2);
	}
	
	action take_passengers_out {
		
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
		//leave this fct even tho it is not used because of the interface Vehicle.gaml
		write "goto on a common transport should not be called! \n go_to_next_stop is used instead" color:#red;
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
//		if current_road != nil {
//			//here we register previous road info in the log
//			float t;
//			ask current_road {
//				t <- get_theoretical_travel_time(myself);
//			}
//			int road_lateness <- int((get_current_date() - log_entry_date) - t);
//			do log(road_lateness);
//		}
//		log_entry_date <- get_current_date();
//		//
		
		color <- driving_color;
		current_road <- road;
		do move_to(road.location);
			
		remove index: 0 from: my_path.edges;
	}
	
	action arrive_at_destination {		
		//delete from previous road
		if current_road != nil {
			//log
//			float t;
//			ask current_road {
//				t <- get_theoretical_travel_time(myself);
//			}
//			int road_lateness <- int((get_current_date() - log_entry_date) - t);
//			do log(road_lateness);
			//
			
//			list<point> p <- current_road.displayed_shape closest_points_with(owner.current_destination);
//			do move_to(p[0]);
			ask current_road {
				bool found <- remove(myself);	
				assert found warning: true;
			}	
		}else{
			write get_current_date() + ": Something is wrong with " + name + "\n Belonging to " + owner.name color:#orange;
		}
		color <- parking_color;
		current_road <- nil;

		do take_passengers_out;
		do take_passengers_in;
	
		if get_current_date() >= trip.departure_times[current_stop_idx] {
			do go_to_next_stop;
		}else{
			do later the_action: "go_to_next_stop" at:trip.departure_times[current_stop_idx];
		}

	}
	
	aspect default {
		draw circle(20) color: color border: #black;
	}
}

