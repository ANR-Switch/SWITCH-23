/**
* Name: Car
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

/*
 * This model is a vehicle (can be used by a Person) and allows the person to use the 
 * Public Transport Network
 */

model PublicTransportCard

import "Vehicle.gaml"

species PublicTransportCard parent: Vehicle schedules: [] {
	list<pair<TransportStop, TransportTrip>> itinerary;
	list<TransportStop> stops;
	list<string> routes;
	list<int> directions;
	int itinerary_idx <- 0;
	Vehicle current_public_transport;
	
	int max_waiting_time <- 40 const:true; //minutes
	
	//debug
	list<string> journal;
//	init {
//		color <- #darkgoldenrod;
//	}
	
	action init_vehicle(Person _owner, float _length<-0.0#meter, float _speed<-5#km/#h, int _seats<-1){
		owner <- _owner;
//		do add_passenger(owner);
//		location <- _owner.location;
//		length <- _length;
//		speed <- _speed;
//		seats <- _seats;
		event_manager <- owner.event_manager;
		add self to: owner.vehicles;
//		owner.current_vehicle <- self;
	}
	
	path compute_path_between(point p1, point p2) {
//		return path_between(feet_road_graph, p1, p2);
		write "Do not use compute_path_between() for PublicTransportCard" color:#red;
		return nil;
	}
	
	action goto(point dest){
		//init
		itinerary_idx <- 0;
		my_destination <- dest;
		location <- owner.location;
		
		ask public_transport_graph {
			myself.itinerary <- get_itinerary_between(myself.location, myself.my_destination);
		}

		if itinerary = nil {
			write get_current_date() + ": " + name + " belonging to: " + owner.name +" is not able to find a itinerary between " + owner.current_building + " and " + owner.next_building color: #red;
			//write "The motion will not be done. \n The activity: " + owner.current_activity.title + " of: " + owner.name + " might be done in the wrong location." color: #orange;
			owner.location <- owner.current_destination;
			ask owner {
				do end_motion;
			}
		}else{
			//display itinerary
//			loop e over: itinerary {
//				if e.value != nil {
//					write owner.name + " " + e.key.real_name + " towards " + e.value.transport_route.long_name;
//				}else{
//					write owner.name + " " + e.key.real_name;
//				}
//			}
			//
			
			if !empty(itinerary) {
				do convert_itinerary(itinerary);
				
				//log
				string s <- get_current_date() + " itinerary: ";
				loop e over: stops {
					s <- s + e.real_name + ";";
				}
				add s to: journal;
				
				do walk_to(stops[0].location);
				do wait_to_stop;
			}else{
				write get_current_date() + ": " + owner.name + " called goto on " + name + " but the path computed is null.";
			}	
		}
	}
	
	action get_in(Vehicle v) {
		current_public_transport <- v;
		
		ask v {
			do add_passenger(myself.owner);
		}
		ask stops[itinerary_idx] {
			do remove_waiting_person(myself);
		}
		
		string s;
		s <- get_current_date() + ": got in " + v.name + " at stop " + stops[itinerary_idx].real_name;
		add s to: journal;
		
		itinerary_idx <- itinerary_idx + 1;
	}
	
	action get_out {	
		ask current_public_transport {
			do remove_passenger(myself.owner);
		}	
		add get_current_date() + ": got out of " + current_public_transport.name  to: journal;
		
		owner.color <- #black;
		current_public_transport <- nil;
		
		
		if length(stops) - 1 = itinerary_idx {
			do end_itinerary;
		}else{
			do wait_to_stop;
		}
	}
	
	action end_itinerary {
		write get_current_date() + ": " + owner.name + " arrived through public transport" color:#green;
		itinerary_idx <- nil;
		my_destination <- nil;
		stops <- [];
		directions <- [];
		routes <- [];
		
		do walk_to(my_destination);		
		ask owner {
			do end_motion;
		}	
	}
	
	action wait_to_stop{
		owner.location <- stops[itinerary_idx].location;
		location <- owner.location;
		add self to: stops[itinerary_idx].waiting_persons;
		do later the_action:"recompute_itinerary" with_arguments:map("idx"::itinerary_idx) at: get_current_date() add_minutes max_waiting_time;
	}
	
	action recompute_itinerary(int idx) {
		//check if we got our correspondance since we started to wait
		//if empty stops it means we actually arrived somewhere before the do later triggers itself
		if idx = itinerary_idx and current_public_transport = nil and my_destination != nil {
			//recompute
			write get_current_date() + ": " + name + " recomputed its path because it seems stuck" color:#orange;
			add get_current_date() + ": recomputed its path because it seems stuck" to: journal;
			
			ask stops[itinerary_idx] {
				do remove_waiting_person(myself);
			}
			do goto(my_destination);
		}
	}
	
	action walk_to(point p){
		//TODO
		owner.location <- p;
		location <- owner.location;
	}
	
//	action skip_connection {
//		if itinerary[itinerary_idx].value != nil {
//			do wait_to_stop(itinerary[itinerary_idx].key);
//			return;
//		}else{
//			itinerary_idx <- itinerary_idx + 1;
//			do skip_connection;
//		}
//	}
	
	action propose {
		write "The mtd propose should not be called on a PublicTransportCard" color:#red;
	}
	
	action enter_road(Road road){
		write "The mtd enter_road should not be called on a PublicTransportCard" color:#red;
	}
	
	action arrive_at_destination {
		//delete from previous road
		/*if current_road != nil {			
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
			write get_current_date() + ": Something is wrong with " + name + "\n Belonging to " + owner.name color:#orange;
		}
		current_road <- nil;
		owner.location <- my_destination;
		
		ask owner {
			do end_motion; //this may kill the vehicle so make sure this is our last action
		}
		*/
	}
	
	action convert_itinerary(list<pair<TransportStop, TransportTrip>> li){
		//this is because the TransportTrip returned in the itinerary will eventually die but we want to save its information
		stops <- [];
		routes <- [];
		directions <- [];
		
		loop e over: li {
			add e.key to: stops;
			if e.value != nil {
				add e.value.route_id to: routes;
				add e.value.direction_id to: directions;	
			}else{
				//last element of itineraruy should only be the destination stop
				add nil to: routes;
				add nil to: directions;
			}
		}
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

