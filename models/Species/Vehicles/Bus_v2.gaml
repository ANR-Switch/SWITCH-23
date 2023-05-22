/**
* Name: Bus
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

/*
 * This should not be a Person's vehicle as it is a public transport system
 */

model Bus_to_change_name

import "../Transports/TransportTrip.gaml"

import "Vehicle.gaml"

species Bus_to_change_name parent: Vehicle schedules: [] {
	rgb parking_color <- #gray;
	rgb driving_color <- #pink;
	
	//bus
	TransportTrip trip;
	int current_stop_idx <- 0;
	list<Road> my_roads;
	
	//useful for debug
	string route;
	string next_stop ; 
	
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
			
//			float t1 <- machine_time;
//			my_path <- compute_path_between(location, trip.stops[current_stop_idx].location);
//			write "bus graph: " + (machine_time - t1) + " miliseconds." color:#green;
			
			my_roads <- trip.bus_path[current_stop_idx-1];
						
			if my_roads = nil {
				//TODO remettre les write
				//write get_current_date() + ": " + name + " for: " + trip.transport_route.long_name +" is not able to find a path between " + trip.stops[current_stop_idx-1] + " and " + trip.stops[current_stop_idx] color: #red;
				//do go_to_next_stop;
				location <- trip.stops[current_stop_idx].location;
				do arrive_at_destination;
			}else{
				if !empty(my_roads) {
					do propose;			
				}else{
					//this happens
					//write get_current_date() + ": " + name + " but the path computed is null.";
//					do go_to_next_stop;
					location <- trip.stops[current_stop_idx].location;
					do arrive_at_destination;
				}	
			}
		}else{
			//we are in terminus
			if current_road != nil {
				ask current_road {
					bool found <- remove(myself);	
					assert found warning: true;
				}	
			}
			current_road <- nil;
	
			//
			if !empty(passengers) {
				write get_current_date() +  ": " + name + " has some passengers still inside even though we are in terminus! :" color:#red;
				PublicTransportCard tc;
				loop p over: passengers {
					tc <- PublicTransportCard(p.current_vehicle);
					write tc.name;
					ask tc {
						do get_out;
					}
				}
			}
			ask trip {
				do end_trip;
			}	
			do die;		
		}
	}
	
	path compute_path_between(point p1, point p2) {
		return path_between(car_road_graph, p1, p2);
	}
	
	action take_passengers_out {
		PublicTransportCard tc;
		list<Person> get_out;

		if name = "Bus561" {
			write "Current stop idx: " + current_stop_idx + "/" + length(trip.stops) ;
		}
		loop p over: passengers {
			tc <- PublicTransportCard(p.current_vehicle);
			
			if trip.stops[current_stop_idx].real_name = tc.stops[tc.itinerary_idx].real_name {
				add p to: get_out;
			}
		}
		
		if name = "Bus561" and !empty(passengers) {
			write trip.stops[current_stop_idx].real_name + " for " + PublicTransportCard(passengers[0].current_vehicle).stops[PublicTransportCard(passengers[0].current_vehicle).itinerary_idx].real_name;
		}
		
		loop p over: get_out {
			write name + " makes " + p.name + " out of the bus";
			write passengers;
			remove all:p from: passengers;
			
			tc <- PublicTransportCard(p.current_vehicle);
			ask tc {
				do get_out;
			}
			
			write passengers;
		}
	}
	
	action take_passengers_in {
		PublicTransportCard tc;
		list<Person> new_passengers;
		ask trip.stops[current_stop_idx] {
			new_passengers <- get_waiting_persons(myself);
		}
		
		loop p over: new_passengers {
			tc <- PublicTransportCard(p.current_vehicle);
			ask tc {
				do get_in(myself);
			}
			do add_passenger(p);
			
			ask trip.stops[current_stop_idx] {
				remove all: PublicTransportCard(p.current_vehicle) from: waiting_persons;
			}
		
			write get_current_date() + ": " + name + " to "  + " takes passenger: " + p.name + " at " + trip.stops[current_stop_idx].real_name ;
			write "Dreictions: sould be: " + last(trip.stops).real_name;
		}
	}
	
	action goto(point dest){
		//leave this fct even tho it is not used because of the interface Vehicle.gaml
		write "goto on a common transport should not be called! \n go_to_next_stop is used instead" color:#red;
	}
	
	action propose {
		//this method is similar to the propose done by roads. It should be used only at the init of the motion
		Road r <- Road(my_roads[0]);
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
			
		remove index: 0 from: my_roads;
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
			//write get_current_date() + ": Something is wrong with " + name color:#orange;
		}
		
		color <- parking_color;
		current_road <- nil;

		do take_passengers_out;
		do take_passengers_in;
	
		if get_current_date() >= trip.departure_times[current_stop_idx] {
			do go_to_next_stop;
//			write name + " is late";
		}else{
			do later the_action: "go_to_next_stop" at: trip.departure_times[current_stop_idx];
//			write name + " is in advance on schedule.";
		}
	}
	
	aspect default {
		draw circle(20) color: color border: #black;
	}
}

