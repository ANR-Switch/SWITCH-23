/**
* Name: World
* Based on the internal empty template. 
* Author: ohauterville
* Tags: 
*/
model World

import "Utilities/Constants.gaml"

import "Utilities/EventManager.gaml"

import "Utilities/Logger.gaml"

import "Species/Map/Road.gaml"

import "Species/Map/Building.gaml"

import "Utilities/Population_builder.gaml"

global {	
	//loading parameters
//	string dataset_path <- "../includes/Castanet-Tolosan/CASTANET-TOLOSAN/";
	string dataset_path <- "../includes/Castanet-Tolosan/TEST/";
	shape_file shape_roads <- shape_file(dataset_path + "road.shp");
//	shape_file shape_nodes <- shape_file(dataset_path + "nodes.shp");
//	shape_file shape_boundary <- shape_file(dataset_path + "bounds.shp");
	shape_file shape_buildings <- shape_file(dataset_path + "buildings.shp");
	geometry shape <- envelope(shape_roads);
	
	//general paramters	 
	date starting_date <- date([1970, 1, 1, 6, 0, 0]);
	date sim_starting_date <- date([1970, 1, 1, 0, 0, 0]); //has to start at midnight! for activity.gaml init
	
//	float step <- 1 #seconds;
	float step <- 1 #minutes;
//	float step <- 1 #hours;
//	float step <- 1 #days;
	int nb_event_managers <- 1;
	
	graph car_road_graph;
	map<Road, float> car_road_weights_map;
	//graph others;
	 
	list<Building> working_buildings;
	list<Building> living_buildings;
	
	init {
		seed <- 42.0;
		float sim_init_time <- machine_time;
		date init_date <- (starting_date + (machine_time / 1000));

		create Constants; //constant file useful for other species
		do init_event_managers; //good to do first
		do init_buildings;
	 	do init_roads;
	 	do init_graphs; //should be done after roads
	 	do init_persons;
	 	
	 	//linkage
	 	do link_persons_to_event_manager(EventManager[0]);
	 	do link_roads_to_event_manager(EventManager[0]);
	 	//final init statement
	 	do register_all_first_activities;
		
		write "Simulation is ready. In " + (machine_time - sim_init_time)/1000.0 + " seconds." ;
	}
	
	action register_all_first_activities {
		loop ppl over: Person {
			assert ppl.event_manager != nil;
			ask ppl {
				do register_first_activity;
			}
		}
	}	
	
	action link_persons_to_event_manager(EventManager e){
		//to be used only if the agents possess the scheduling skill
		loop p over: Person {
			p.event_manager <- e;
		}
	}
	
	action link_roads_to_event_manager(EventManager e){
		//to be used only if the agents possess the scheduling skill
		loop r over: Road {
			r.event_manager <- e;
		}
	}
	
	action init_event_managers{
		create EventManager number: nb_event_managers;
	}
	
	action init_persons {
		//create the persons
		write "Persons...";
		float t1 <- machine_time;
		create Population_builder {
			sim_starting_date <- myself.sim_starting_date;
			working_buildings <- myself.working_buildings;
			living_buildings <- myself.living_buildings;
			do initialize_population;
		}
		write "There are " + length(Person) + " Persons loaded in " + (machine_time-t1)/1000.0 + " seconds.";
	}
	
	action init_buildings {
	 	write "Buildings...";
	 	float t1 <- machine_time;
		create Building from: shape_buildings with: [type::int(read("type"))]{
			switch int(type) {
				match 0 {
					color <- #gray;				
					add self to: myself.living_buildings;
				}
				match 1 {
					color <- #blue;				
					add self to: myself.working_buildings;
				}
				match 2 {
					color <- #blue;				
					add self to: myself.working_buildings;
				}
				match 4 {
					color <- #red;				
					add self to: myself.working_buildings;
				}
				default {
					color <- #green;
				}	
			}
		}
		write "There are " + length(Building) + " Buildings loaded in " + (machine_time-t1)/1000.0 + " seconds.";
	 }
	 
	 action init_roads {
	 	write "Roads...";
	 	float t1 <- machine_time;
	 	//car roads
		create Road from: shape_roads with: [lanes::int(read("nb_lane")), 
											max_speed::float(read("max_speed")),
											oneway::string(read("one_way")),
											id::int(read("id")),
											allowed_vehicles::list<list<int>>(read("vehicles"))
		]{
		}
		
//		//doublement
//		int nb_roads <- length(Road);
//		loop r over: Road {
//			if r.oneway != "F" {
//				create Road {
//					shape <- line(reverse(r.shape.points));
//					id <- nb_roads + r.id;
//					lanes <- r.lanes;
//					max_speed <- r.max_speed;
//					oneway <- r.oneway;
//				}
//			}
//		}

		//separation
//		list<Road> car_roads <- Road collect each.car_auth;

		car_road_weights_map <- Road as_map (each:: (each.shape.perimeter/each.max_speed));
		write "There are " + length(Road) + " Roads loaded in " + (machine_time-t1)/1000.0 + " seconds.";
	 }
	 
	 action init_graphs {
	 	write "Graphs...";
	 	car_road_graph <- as_edge_graph(Road) with_weights car_road_weights_map;
	 	car_road_graph <- directed(car_road_graph);
	 	write "Graphs are ready.";
	 }

}


experiment "test CT" type: gui {
	output {
		display main_window type: opengl {
			species Road;
			species Building;
			species Person;
//			species Bike;
//			species Car;
//			species Truck;
		}
		
		display "chart_display" {
	        chart "lateness_chart" type: histogram {
	        	datalist  (distribution_of(Person collect (each.total_lateness/length(each.personal_agenda.activities)),6,0, Person max_of(each.total_lateness/length(each.personal_agenda.activities))) at "legend") 
	            value:(distribution_of(Person collect (each.total_lateness/length(each.personal_agenda.activities)),6,0,Person max_of(each.total_lateness/length(each.personal_agenda.activities))) at "values");      
	        } 
        }
		
//		monitor "Time: " value: current_date;

	}

}
