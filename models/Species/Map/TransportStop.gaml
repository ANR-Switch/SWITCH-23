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
	
	//simu
	list<pair<Person, string>> waiting_persons;
	

	list<Person> get_waiting_persons(Vehicle v){
		list<Person> return_list;
		
		switch species(v){
			match Bus { //TODO +TC
				Bus bus <- Bus(v);
				loop p over: waiting_persons {
					if p.value = bus.trip.route_id {
						add p.key to: return_list;
					}
				}
			}
		}
		
		
		return return_list;
	}
	
	action add_person_to_waiting_persons_list (Person p, string desired_transport) {
		add p::desired_transport to: waiting_persons;
	}
	
	
	aspect default {
		draw square(25) color: #purple;
	}
}