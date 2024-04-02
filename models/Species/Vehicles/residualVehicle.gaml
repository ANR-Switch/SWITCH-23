/**
* Name: residualVehicle
* Based on the internal empty template. 
* Author: flavi
* Tags: 
*/


model ResidualVehicle

import "../Map/ResidualFlow.gaml"

//import "../../Logs/Logger.gaml"

import "../Map/RoadsGraph.gaml"


import "../Person.gaml"

//import "../../World.gaml"


/*
 * this class is an interface of all the transportation modes
 */

species ResidualVehicle parent: Car skills: [scheduling] schedules: [] {
	float length;
	float speed <- 0.0 #km / #h;
	point my_destination;
	path my_path;
	Road current_road <- nil;
	date log_entry_date;	
	graph my_graph;
	graph graph_pound;
	Logger log;
	int id;
	ResidualFlow start_autoroute;
	ResidualFlow dest_autoroute;

	//
		
	//for traffic conditions used by the road agents (default values are for a car)
	float traffic_influence <- 1.0; //strength of our influence on the traffic, should be 1 for cars bus and trucks, and less for bikes
		
	init {
		my_graph <- car_road_graph;
		speed <- 130#km/#h;
	}



	
	action go_to(point start, point dest){
		nb_trajet <- nb_trajet+1;

			current_road <- nil;
			float t1 <- machine_time;

			my_path <- path_between(my_graph, start, dest);
			if my_path = nil {
				if pathNotFound < 1{
					write ("path not found !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
					add location to:missed_start;
					add dest to:missed_start;
				}
			}
			else{
				if !empty(my_path.edges) {
					do propose;
				}else{
					//ask log{do log(myself.get_current_date() + ": " + myself.owner.name + " called goto on " + myself.name + " but the path computed is null.");} 
				}	
			}
	}
	
	action propose {
		//this method is similar to the propose done by roads. It should be used only at the init of the motion
		Road r <- Road(my_path.edges[0]);
		ask r {
			do treat_proposition(myself);
		}
	}
	
	
	action move_to(point loc){
		location <- loc;
	}
	
	action enter_road(Road road){
		if current_road != nil {
			//here we register previous road info in the log
			float t;
			ask current_road {
				t <- get_theoretical_travel_time(myself);
			}
			int road_lateness <- int((get_current_date() - log_entry_date) - t);
	
			do log_lateness(road_lateness);

			
		}
		log_entry_date <- get_current_date();
		current_road <- road;
		//write"moveto";
		do move_to(road.location);
		remove index:0 from: my_path.edges;
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
			do log_lateness(road_lateness);
			//location <- current_road.location;
			//
			
			ask current_road {
				bool found <- remove(myself);	
				assert found warning: true;
			}	
		}
		current_road <- nil;
		//owner.location <- location;
		
	}
	
	
	/*action log_lateness (int _lateness){
		date leave_date <- get_current_date();
		float distance <- current_road.shape.perimeter;
		float mean_speed <- distance / (leave_date - log_entry_date);
		float time_on_road <- (leave_date - log_entry_date);
		mean_speed <- (mean_speed * 3.6) with_precision 1;

		//write self.current_road.name;
		
		
		//add string(owner.act_idx)+","+self.name+","+self.current_road.name+","+self.current_road.topo_id+","+round(distance)+","+self.log_entry_date+","+string(leave_date)+","+round(mean_speed)+","+_lateness to: owner.journal_str;
	}*/
}

