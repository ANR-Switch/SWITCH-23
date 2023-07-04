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
	date start <- nil;
	
	int max_waiting_time <- Constants[0].waiting_time_before_recomputing; //minutes
	
	//debug
	list<string> journal;
	string tmp_log;
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
		
		if my_destination != location {
//			if distance_to(my_destination, location) < 500 {
//				write owner.name + " short ditance" color:#green;
//				//TODO walk instead
//			}
			try {
				ask public_transport_graph {
					myself.itinerary <- get_itinerary_between(myself.location, myself.my_destination);
				}	
			}catch {
				
			}
	
			if itinerary = nil {
				write get_current_date() + ": " + name + " belonging to: " + owner.name +" is not able to find a itinerary between " + owner.current_building + " and " + owner.next_building color: #red;
				//write "The motion will not be done. \n The activity: " + owner.current_activity.title + " of: " + owner.name + " might be done in the wrong location." color: #orange;
				owner.location <- owner.current_destination;
				add get_current_date() + ": got an empty itinerary!" to: journal;
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
					
					if start = nil {
						start <- get_current_date();
					}
					
					//log
					string s <- get_current_date() + ": trip: "+ owner.act_idx + " itinerary: ";
					loop e over: stops {
						s <- s + e.real_name + ";";
					}
					add s to: journal;
					
					do go_on_itinerary;
//					do walk_to(stops[0].location);
//					do wait_to_stop;
				}else{
					write get_current_date() + ": " + owner.name + " called goto on " + name + " but the path computed is empty." color:#red;
					write distance_to(owner.location, owner.current_destination);
					owner.location <- owner.current_destination;
					add get_current_date() + ": got an empty itinerary!" to: journal;
					ask owner {
						do end_motion;
					}
				}	
			}
		}else{
			write get_current_date() + ": " + owner.name + " is already at destination, it will not use " + name;
			ask owner {				
				do end_motion;
			}			
		}
	}
	
	action get_in(Vehicle v) {		
		ask v {
			do add_passenger(myself.owner);
		}
		
		if v.passengers contains owner { //false when the bus is full and cannot add owner to its passengers
			ask stops[itinerary_idx] {
				do remove_waiting_person(myself);
			}
			
			tmp_log <- string(owner.act_idx) + "," + v.name + "," + get_current_date() + ", " + stops[itinerary_idx].real_name;
			//add s to: owner.journal_str;
			
			itinerary_idx <- itinerary_idx + 1;	
			current_public_transport <- v;
		}
	}
	
	action get_out {	
		ask current_public_transport {
			do remove_passenger(myself.owner);
		}	
		
		//log
		int t <- int((get_current_date() - start)/60); //minutes spent in this trip
		switch species(current_public_transport) {
			match Bus {
				add tmp_log + "," + get_current_date() + "," + Bus(current_public_transport).trip.stops[Bus(current_public_transport).current_stop_idx].real_name + "," + Bus(current_public_transport).trip.transport_route.long_name + "," + t to: owner.journal_str;
				//add get_current_date() + ": got out of " + current_public_transport.name + " at stop " + Bus(current_public_transport).trip.stops[Bus(current_public_transport).current_stop_idx].real_name to: owner.journal_str;
			}
			match Metro {
				add tmp_log + "," + get_current_date() + "," + Metro(current_public_transport).trip.stops[Metro(current_public_transport).current_stop_idx].real_name + "," + Metro(current_public_transport).trip.transport_route.long_name + "," + t to: owner.journal_str;
				//add get_current_date() + ": got out of " + current_public_transport.name + " at stop " + Metro(current_public_transport).trip.stops[Metro(current_public_transport).current_stop_idx].real_name to: owner.journal_str;
			}
			match Tramway {
				add tmp_log + "," + get_current_date() + "," + Tramway(current_public_transport).trip.stops[Tramway(current_public_transport).current_stop_idx].real_name + "," + Tramway(current_public_transport).trip.transport_route.long_name + "," + t to: owner.journal_str;
				//add get_current_date() + ": got out of " + current_public_transport.name + " at stop " + Tramway(current_public_transport).trip.stops[Tramway(current_public_transport).current_stop_idx].real_name to: owner.journal_str;
			}
			match Teleo {
				add tmp_log + "," + get_current_date() + "," + Teleo(current_public_transport).trip.stops[Teleo(current_public_transport).current_stop_idx].real_name + "," + Teleo(current_public_transport).trip.transport_route.long_name + "," + t to: owner.journal_str;
				//add get_current_date() + ": got out of " + current_public_transport.name + " at stop " + Teleo(current_public_transport).trip.stops[Teleo(current_public_transport).current_stop_idx].real_name to: owner.journal_str;
			}
		}
		
		owner.color <- #black;
		current_public_transport <- nil;
		
		
		if length(stops) - 1 = itinerary_idx {
			do end_itinerary;
		}else{
			do go_on_itinerary;
		}
	}
	
	action go_on_itinerary {
		if itinerary_idx < length(routes) {
			if routes[itinerary_idx] != nil {
				do wait_to_stop;	
			}else{
				itinerary_idx <- itinerary_idx +1;
				//write get_current_date() + ": " + owner.name  + " walks from one stop to another.";
				add get_current_date() + ": " + owner.name  + " walks from one stop to another." to: journal;
				do later the_action: "go_on_itinerary" at: get_current_date() add_minutes 2;
			}
		}else{
			do end_itinerary;
		}
	}
	
	action end_itinerary {
		//write get_current_date() + ": " + owner.name + " arrived through public transports in " + (get_current_date() - start)/60 + " minutes." color:#green;
		add get_current_date() + ": " + (get_current_date() - start)/60 + " minutes." to: journal;
	
		itinerary_idx <- nil;
		start <- nil;
		my_destination <- nil;
		stops <- [];
		directions <- [];
		routes <- [];
		
		do walk_to(my_destination);	
		add get_current_date() + ": arrived successfully." to: journal;	
		ask owner {
			do end_motion;
		}	
	}
	
	action wait_to_stop{
		owner.location <- stops[itinerary_idx].location;
		location <- owner.location;
		add self to: stops[itinerary_idx].waiting_persons;
		do later the_action:"recompute_itinerary" with_arguments:map("old_position"::location) at: get_current_date() add_minutes max_waiting_time;
	}
	
	action recompute_itinerary(point old_position) {
		//check if we got our correspondance since we started to wait
		if !empty(stops) and old_position = owner.location and current_public_transport = nil {
			//recompute			
			if TransportTrip count(each.alive) != 0 {
				add get_current_date() + ": recomputed its path because it seems stuck" to: journal;
				ask stops[itinerary_idx] {
					do remove_waiting_person(myself);
				}
				do goto(my_destination);	
			}else{
				//there are no public transports no more
				write get_current_date() + ": " + owner.name +" is stuck and there are no public transports available at this hour." color:#orange;
				add get_current_date() + ": is stuck and there are no public transports available at this hour." to: journal;
				do end_itinerary;
			}
		}else{
			//write "all good" color:#green;
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

