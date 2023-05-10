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
		list<Person> return_list;
		
		switch species(v){
			match Bus {
				Bus bus <- Bus(v);
				loop p over: waiting_persons {
					if p.routes[p.itinerary_idx] = bus.trip.route_id and p.directions[p.itinerary_idx] = bus.trip.direction_id {
						add p.owner to: return_list;
					}
				}
			}
			match Metro {
				Metro metro <- Metro(v);
				loop p over: waiting_persons {
					if p.routes[p.itinerary_idx] = metro.trip.route_id and p.directions[p.itinerary_idx] = metro.trip.direction_id {
						add p.owner to: return_list;
					}
				}
			}
			match Tramway {
				Tramway tramway <- Tramway(v);
				loop p over: waiting_persons {
					if p.routes[p.itinerary_idx] = tramway.trip.route_id and p.directions[p.itinerary_idx] = tramway.trip.direction_id {
						add p.owner to: return_list;
					}
				}
			}
			match Teleo {
				Teleo teleo <- Teleo(v);
				loop p over: waiting_persons {
					if p.routes[p.itinerary_idx] = teleo.trip.route_id and p.directions[p.itinerary_idx] = teleo.trip.direction_id {
						add p.owner to: return_list;
					}
				}
			}
		}		
		
		return return_list;
	}
	
//	action add_person_to_waiting_persons_list (Person p, string desired_transport) {
//		add p::desired_transport to: waiting_persons;
//	}
	
	
	aspect default {
		draw square(25) color: color;
	}
}