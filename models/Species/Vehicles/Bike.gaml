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

import "Vehicle.gaml"

species Bike parent: Vehicle schedules: [] {
	
	init {
		color <- #limegreen;
	}
	
	action init_vehicle(Person _owner, float _length<-0.0#meter, float _speed<-22#km/#h, int _seats<-1){
		owner <- _owner;
//		do add_passenger(owner);
		location <- _owner.location;
		length <- _length;
		speed <- _speed;
		seats <- _seats;
		event_manager <- owner.event_manager;
		add self to: owner.vehicles;
//		owner.current_vehicle <- self;
	}
	
	path compute_path_between(point p1, point p2) {
		return path_between(bike_road_graph, p1, p2);
	}
	
	action goto(point dest){
		if !empty(passengers) {
			//init
			current_road <- nil;
			owner.location <- location;
			my_destination <- dest;
			
			float t1 <- machine_time;
			my_path <- compute_path_between(location, my_destination);
			_miliseconds <- _miliseconds + (machine_time - t1);
//			write "time : >>> " + (machine_time - t1) + " milliseconds" color: #green;

			if my_path = nil {
				write get_current_date() + ": " + name + " belonging to: " + owner.name +" is not able to find a path between " + owner.current_building + " and " + owner.next_building color: #red;
				owner.location <- owner.current_destination;
				ask owner {
					do end_motion;
				}
			}else{
				if !empty(my_path.edges) {
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
			
			ask current_road {
				bool found <- remove(myself);	
				assert found warning: true;
			}	
		}else{
			write get_current_date() + ": " + name + "\n Belonging to " + owner.name + " does not have a path." color:#orange;
		}
		current_road <- nil;
		owner.location <- my_destination;
		
		ask owner {
			do end_motion; //this may kill the vehicle so make sure this is our last action
		}
	}
}

