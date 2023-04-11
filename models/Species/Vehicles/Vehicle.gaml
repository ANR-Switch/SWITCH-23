/**
* Name: Vehicle
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Vehicle

import "../../World.gaml"

/*
 * this class is an interface of all the transportation modes
 */

species Vehicle virtual: true skills: [scheduling] schedules: [] {
	rgb color;
	float length;
	float speed <- 0.0 #km / #h;
	Person owner;
	list<Person> passengers;
	int seats <- 1;
	point my_destination;
	path my_path;
	Road current_road <- nil;
	date log_entry_date;	
	//
		
	//for traffic conditions used by the road agents (default values are for a car)
	float traffic_influence <- 1.0; //strength of our influence on the traffic, should be 1 for cars bus and trucks, and less for bikes
		
	action init_vehicle(Person _owner, float _length<-2.0, float _speed<-30#km/#h, int _seats<-1) virtual: true;
	action goto(point dest) virtual: true;
	action enter_road(Road road) virtual: true;
	action arrive_at_destination virtual: true;
	path compute_path_between(point p1, point p2) virtual: true;
	
	//same for everyone
//	date get_current_date{
//		date _d;
//		ask owner {
//			_d <- get_current_date();
//		}
//		return _d;
//	}
	
	action add_passenger(Person p){
		if length(passengers) < seats {
			add p to: passengers;
		}else{
			write get_current_date() + ": " + name + " tries to add: "+ p.name + " to itself but it is already full." color:#red;
		}
	}
	
	action remove_passenger(Person p){
		if passengers contains p {
			remove p from: passengers;
		}else{
			write get_current_date() + ": " + name + " tries to remove: "+ p.name + " but it is not here." color:#red;
		}
	}
	
	action move_to(point loc){
		location <- loc;
		loop p over: passengers {
			p.location <- location;
			p.color <- color;
		} 
	}
	
	action log (int _lateness){
		date leave_date <- get_current_date();
		float distance <- current_road.shape.perimeter;
		float mean_speed <- distance / (leave_date - log_entry_date);
		mean_speed <- (mean_speed * 3.6) with_precision 1;
		ask owner.journal {
			do write_in_journal(myself.owner.act_idx, myself.name, myself.current_road.name, round(distance), myself.log_entry_date, leave_date, mean_speed, _lateness);
		}
	}
}

