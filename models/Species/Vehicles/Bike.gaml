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
	
	action init {
//		has_width <- false;
		traffic_influence <- 0.0;
		subject_to_flow <- true;
	}
	
	action init_vehicle(Person _owner, float _length<-2.0#meter, float _speed<-30#km/#h, int _seats<-1){
		owner <- _owner;
//		do add_passenger(owner);
		location <- _owner.location;
		length <- _length;
		speed <- _speed;
		seats <- _seats;
		owner.vehicle <- self;
	}
	
	action goto(point dest){
		if !empty(passengers) {
			//init
			current_road <- nil;
			owner.location <- location;
			my_destination <- dest;
//			float t1 <- machine_time;
			my_path <- path_between(car_road_graph, location, my_destination);
//			write "time : >>> " + (machine_time - t1) + " milliseconds" color: #green;
			if my_path = nil {
				write get_current_date() + ": " + name + " is not able to find a path between " + location + " and " + my_destination color: #red;
				write "The motion will not be done. \n The activity: " + owner.current_activity.title + " of: " + owner.name + " might be done in the wrong location." color: #orange;
				ask owner {
					do end_motion;
				}
			}else{
				if !empty(my_path.edges) {
					//compute theoretical arrival date for comparaison at the end of the simulated day
					theoretical_arrival_date <- get_current_date() add_seconds compute_theoretical_time();
					owner.theoretical_travel_duration <- compute_theoretical_time();
//					write "Trip should last " + compute_theoretical_time() color:#purple;
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
		current_road <- road;
		location <- road.location;
		loop p over: passengers {
			p.location <- location;
		} 
//		owner.location <- self.location;
		owner.color <- #green;
		remove index: 0 from: my_path.edges;
	}
	
	action arrive_at_destination {
		//delete from previous road
		if current_road != nil {
			ask current_road {
				bool found <- remove(myself);	
				assert found warning: true;
			}	
		}else{
			write get_current_date() + ": " + name + "\n Belonging to " + owner.name + " does not have a path." color:#orange;
		}
		current_road <- nil;
		owner.location <- my_destination;
		
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
		
		ask owner {
			do end_motion; //this may kill the vehicle so make sure this is our last action
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
}

