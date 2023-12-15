/**
* Name: Vehicle
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Vehicle

//import "../../Logs/Logger.gaml"

import "../Map/RoadsGraph.gaml"


import "../Person.gaml"

//import "../../World.gaml"


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
	graph my_graph;
	Logger log;
	//
		
	//for traffic conditions used by the road agents (default values are for a car)
	float traffic_influence <- 1.0; //strength of our influence on the traffic, should be 1 for cars bus and trucks, and less for bikes
		
	action init_vehicle(Person _owner, Logger l) {
			log<- l;
			
	}

	
	path compute_path_between(point p1, point p2) {
		path current_path_asmap;
		path current_path_graph;
		
		current_path_asmap <- path_between(my_graph as_map(Road(each)::Road(each).compute_time()), p1, p2);
		current_path_graph <- path_between(my_graph, p1, p2);
		
		write "my graph : " + my_graph;
		/*write "my graph as map : "+my_graph as_map(Road(each)::Road(each).compute_time());
		write "graph : "+current_path_graph;
		write "map : "+current_path_asmap;*/
		return current_path_asmap;
		
		
		
		//path var0 <- path_between (cell_grid as_map (each::each.is_obstacle ? 9999.0 : 1.0), ag1, ag2); // var0 equals A path between ag1 and ag2 passing through the given cell_grid agents with a minimal cost 
	}
	
	action goto(point dest){
		
		if !empty(passengers) {
			//init
			current_road <- nil;
			owner.location <- location; //not necessary I think since its at init
			my_destination <- dest;
			
			float t1 <- machine_time;
			my_path <- compute_path_between(location, my_destination);
			//_miliseconds <- _miliseconds + (machine_time - t1);
//			write "time : >>> " + (machine_time - t1) + " milliseconds" color: #green;

			if my_path = nil {
				if(verbosePathNotFound){
					ask log{
						do log(''+myself.get_current_date()+": "+myself.name+" belonging to: " + myself.owner.name+" is not able to find a path between "+ myself.owner.current_building+ " and " + myself.owner.next_building); //);// + ": " + myself.name + " belonging to: " + owner.name +" is not able to find a path between " + owner.current_building + " and " + owner.next_building color: #red;);}
					}
				}
				owner.location <- owner.current_destination;
				ask owner {
					do end_motion;
				}
			}else{
				if !empty(my_path.edges) {
					do propose;
				}else{
					ask log{do log(myself.get_current_date() + ": " + myself.owner.name + " called goto on " + myself.name + " but the path computed is null.");} 
				}	
			}
		}else{
			ask log{
				do log(myself.get_current_date() + ": " + myself.name + " is asked to go somewhere without a driver !");
			} 
		}
	}
	
	action propose {
		//this method is similar to the propose done by roads. It should be used only at the init of the motion
		write my_path.edges[0];
		Road r <- Road(my_path.edges[0]);
		write r;
		ask r {
			msg_sent <- msg_sent+1;
			do treat_proposition(myself);
		}
	}
	
	//same for everyone
	date get_current_date{
		date _d;
		ask owner {
			_d <- get_current_date();
		}
		return _d;
	}
	
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
	
	action enter_road(Road road){
		//log
		if current_road != nil {
			//here we register previous road info in the log
			float t;
			ask current_road {
				t <- get_theoretical_travel_time(myself);
			}
			int road_lateness <- int((get_current_date() - log_entry_date) - t);
			if latenesslogged{
				do log_lateness(road_lateness);
			}
			
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
			if latenesslogged{
				do log_lateness(road_lateness);
			}
			
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
	
	
	action log_lateness (int _lateness){
		date leave_date <- get_current_date();
		float distance <- current_road.shape.perimeter;
		float mean_speed <- distance / (leave_date - log_entry_date);
		mean_speed <- (mean_speed * 3.6) with_precision 1;
		/*ask owner.journal {
			do write_in_journal(myself.owner.act_idx, myself, myself.current_road.name, myself.current_road.topo_id, round(distance), myself.log_entry_date, leave_date, mean_speed, _lateness);
		}*/
		ask log{
			do log(string(myself.owner.act_idx)+","+myself.name+","+myself.current_road.name+","+myself.current_road.topo_id+","+round(distance)+","+myself.log_entry_date+","+string(leave_date)+","+round(mean_speed)+","+_lateness);
			
		}
		//add string(owner.act_idx)+","+self.name+","+self.current_road.name+","+self.current_road.topo_id+","+round(distance)+","+self.log_entry_date+","+string(leave_date)+","+round(mean_speed)+","+_lateness to: owner.journal_str;
	}
}

