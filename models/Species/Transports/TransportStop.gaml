/**
* Name: Stop
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportStop

import "../Person.gaml"

/* Insert your model definition here */

species TransportStop schedules: [] {
	string id;
	int code;
	string real_name;
	rgb color <- #purple;
	
	//simu
	list<PublicTransportCard> waiting_persons;
	

	list<Person> get_waiting_persons(Vehicle v){
		list<Person> return_list <- [];
	
		if !empty(waiting_persons) {
			switch species(v){
				match Bus {
					Bus bus <- Bus(v);
					//write string(bus.trip.route_id) + " asks " + real_name;
					//and p.directions[p.itinerary_idx] = bus.trip.direction_id
					loop p over: waiting_persons {
						if p.routes[p.itinerary_idx] = bus.trip.route_id  {
							loop i from:bus.current_stop_idx + 1 to: length(bus.trip.stops) - 1 {
								//write bus.trip.stops[i].real_name;
								if i < length(bus.trip.stops) and bus.trip.stops[i].real_name = p.stops[p.itinerary_idx+1].real_name and !(return_list contains p.owner){
									//check if the bus will pass through the next stop of the person (ie where person wants to get out of the bus)
									//we do this check because some lines have different terminus despite having the same id
									add p.owner to: return_list;
								} 
							}
						}
					}
				}
				match Metro {
					Metro metro <- Metro(v);
					loop p over: waiting_persons {
						if p.routes[p.itinerary_idx] = metro.trip.route_id and p.directions[p.itinerary_idx] = metro.trip.direction_id {
							loop i from:metro.current_stop_idx + 1 to: length(metro.trip.stops) - 1 {
								if i < length(metro.trip.stops) and metro.trip.stops[i].real_name = p.stops[p.itinerary_idx+1].real_name and !(return_list contains p.owner){
									//check if the bus will pass through the next stop of the person (ie where person wants to get out of the bus)
									//we do this check because some lines have different terminus despite having the same id
									add p.owner to: return_list;
								} 
							}
						}
					}
				}
				match Tramway {
					Tramway tramway <- Tramway(v);
					loop p over: waiting_persons {
						if p.routes[p.itinerary_idx] = tramway.trip.route_id and p.directions[p.itinerary_idx] = tramway.trip.direction_id {
							loop i from:tramway.current_stop_idx + 1 to: length(tramway.trip.stops) - 1 {
								if i < length(tramway.trip.stops) and tramway.trip.stops[i].real_name = p.stops[p.itinerary_idx+1].real_name and !(return_list contains p.owner){
									//check if the bus will pass through the next stop of the person (ie where person wants to get out of the bus)
									//we do this check because some lines have different terminus despite having the same id
									add p.owner to: return_list;
								} 
							}
						}
					}
				}
				match Teleo {
					Teleo teleo <- Teleo(v);
					loop p over: waiting_persons {
						if p.routes[p.itinerary_idx] = teleo.trip.route_id and p.directions[p.itinerary_idx] = teleo.trip.direction_id {
							loop i from:teleo.current_stop_idx + 1 to: length(teleo.trip.stops) - 1 {
								if i < length(teleo.trip.stops) and teleo.trip.stops[i].real_name = p.stops[p.itinerary_idx+1].real_name and !(return_list contains p.owner){
									//check if the bus will pass through the next stop of the person (ie where person wants to get out of the bus)
									//we do this check because some lines have different terminus despite having the same id
									add p.owner to: return_list;
								} 
							}
						}
					}
				}	
			}
		}		
		
		return return_list;
	}
	
//	action add_person_to_waiting_persons_list (Person p, string desired_transport) {
//		add p::desired_transport to: waiting_persons;
//	}

	action remove_waiting_person(PublicTransportCard p){
		if waiting_persons contains p {
			remove all: p from: waiting_persons;
			//write real_name + " " + id + " " +  waiting_persons color: #green;
		}else{
			write name + " was asked to remove " + p.name + " from its list but it is not here." color:#orange;
		}
		
	}
	
	
	aspect default {
		draw square(25) color: color;
	}
}