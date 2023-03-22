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
	float step <- 360 #seconds parameter: "Step"; //86400 for a day
	float simulated_days <- 1 #days parameter: "Simulated_days";
	float experiment_init_time;
	
	//loading parameters
	string dataset_path <- "../includes/Castanet-Tolosan/CASTANET-TOLOSAN/";
//	string dataset_path <- "../includes/Castanet-Tolosan/TEST/";
	shape_file shape_roads <- shape_file(dataset_path + "road.shp");
//	shape_file shape_nodes <- shape_file(dataset_path + "nodes.shp");
//	shape_file shape_boundary <- shape_file(dataset_path + "bounds.shp");
	shape_file shape_buildings <- shape_file(dataset_path + "buildings.shp");
	geometry shape <- envelope(shape_roads);
	
	//general paramters	 
	date starting_date <- date([1970, 1, 1, 6, 0, 0]);
	date sim_starting_date <- date([1970, 1, 1, 0, 0, 0]); //has to start at midnight! for activity.gaml init

	//modality
	float feet_weight <- 0.0 parameter: "Feet";
	float bike_weight <- 0.0 parameter: "Bike";
	float car_weight <- 0.6 parameter: "Car";
	//highlight path
	int Person_idx <- 0 parameter: "Person_idx";
	int Path_idx <- 0 parameter: "Path_idx";

	int nb_event_managers <- 1;
	
	graph car_road_graph;
//	map<Road, float> car_road_weights_map;
	graph feet_road_graph;
//	map<Road, float> feet_road_weights_map;
	graph bike_road_graph;
//	map<Road, float> bike_road_weights_map;
	//graph others;
	 
	list<Building> working_buildings;
	list<Building> living_buildings;
	list<Building> leasure_buildings;
	list<Building> studying_buildings;
	list<Building> commercial_buildings;
	list<Building> administrative_buildings;
	list<Building> exterior_working_buildings;
	
	init {
		seed <- 42.0;
		float sim_init_time <- machine_time;
		date init_date <- (starting_date + (machine_time / 1000));

		do normalize_modality();
		
		////Constants and Logger
		create Constants; //constant file useful for other species
		create Logger; //logger
		
		//init
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
					color <- #cyan;				
					add self to: myself.studying_buildings;
				}
				match 3 {
					color <- #red;				
					add self to: myself.commercial_buildings;
				}
				match 4 {
					color <- #orange;				
					add self to: myself.administrative_buildings;
				}
				match 5 {
					color <- #green;				
					add self to: myself.leasure_buildings;
				}
				match 6 {
					color <- #purple;
					add self to: myself.exterior_working_buildings; //exterior attraction zones
				}
				default {
					color <- #yellow;
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
											allowed_vehicles::unknown(read("vehicles"))
		]{
			//
		}
		write "There are " + length(Road) + " Roads loaded in " + (machine_time-t1)/1000.0 + " seconds.";
	 }
	 
	 action init_graphs {
	 	write "Graphs...";
	 	float t1 <- machine_time;
	 	//TODO
	 	list<Road> road_subset;
	 	map<Road, float> road_weights_map;
	 	
	 	//feet 
	 	road_subset <- Road where (each.max_speed < 80);
	 	road_weights_map <- road_subset as_map (each:: (each.shape.perimeter));
	 	feet_road_graph <- as_edge_graph(road_subset) with_weights road_weights_map;
	 	write "Pedestrians can use " + length(road_subset) + " road segments.";
	 	
	 	//bike
	 	road_subset <- Road where (each.max_speed < 80);
	 	road_weights_map <- road_subset as_map (each:: (each.shape.perimeter));
	 	bike_road_graph <- as_edge_graph(road_subset) with_weights road_weights_map;
	 	write "Cyclists can use " + length(road_subset) + " road segments.";
	 	
	 	//car
	 	road_subset <- Road where (each.car_track);
	 	road_weights_map <- road_subset as_map (each:: (each.shape.perimeter/each.max_speed));
	 	car_road_graph <- as_edge_graph(Road) with_weights road_weights_map;
	 	car_road_graph <- directed(car_road_graph);
	 	write "Cars can use " + length(road_subset) + " road segments.";
	 	write "Graphs created in " + (machine_time-t1)/1000.0 + " seconds.";
	 }
	 
	 action normalize_modality {
	 	float sum <- feet_weight + bike_weight + car_weight;
	 	feet_weight <- feet_weight / sum ;
	 	bike_weight <- bike_weight / sum ;
	 	car_weight <- car_weight / sum ;
	 }
	 
	 reflex { 
		if cycle = 0 {
			//start
			experiment_init_time <- machine_time;
		}
	 	if Person count(each.day_done) = length(Person) {
	 		ask Logger[0] {
	 			do final_log;
	 		}
	 		write "\n The experiment lasted for: " + (machine_time - experiment_init_time)/1000.0 + " seconds.";
	 		do pause;
	 	}
	 }

}


experiment "Display & Graphs" type: gui {
	/*
	 * Parameters
	 */
	parameter "Step" var: step category: "Simulation step in second" min:1.0 ;
	parameter "Simulated_days" var: simulated_days category: "Simulation days" min:1.0 #days;
	parameter "Pedestrians" var: feet_weight category: "modality" min:0.0;
	parameter "Bikes" var: bike_weight category: "modality" min:0.0;
	parameter "Cars" var: car_weight category: "modality" min:0.0;
	
	/*
	 * Interactive commands
	 */
	parameter "Person to select" var: Person_idx category: "Highlight path" min:0 ;
	parameter "Path to highlight" var: Path_idx category: "Highlight path" min:0;
	user_command "Display parameter" category: "Highlight path" color:#red {
		if Person_idx < length(Person) and Person_idx > -1 {
			ask Person[Person_idx] {do highlight_path(Path_idx);}
		}else{
			write "Person_idx is out of range ! Try again." color:#red;
		}
		
	}
	
	/*
	 * Outputs
	 */
	output {
		display main_window type: opengl {
			species Road;
			species Building;
			species Person;
			species Car;
		}
		
		display "chart_display" {
	        chart "Mean per-travel-lateness" type: histogram {
	        	datalist  (distribution_of(Person collect (each.total_lateness/(length(each.personal_agenda.activities))),6,0, Person max_of(each.total_lateness/(length(each.personal_agenda.activities)))) at "legend") 
	            value:(distribution_of(Person collect (each.total_lateness/(length(each.personal_agenda.activities))),6,0,Person max_of(each.total_lateness/(length(each.personal_agenda.activities)))) at "values");      
	        } 
        }
        
        display "Persons moving" {
        	chart "Moving persons" type: series {
        		data "Persons moving" value: Person count(each.is_moving_chart = true) color:#black;
        	}
        } 
        
        display "Part modales" {
        	chart "Parts modales" type: pie {
        		data "Cars" value: Person count(each.is_moving_chart and species(each.current_vehicle)=Car) color: #yellow;
        		data "Bikes" value: Person count(each.is_moving_chart and species(each.current_vehicle)= Bike) color: #limegreen;
        		data "Pedestrians" value: Person count(each.is_moving_chart and species(each.current_vehicle)= Feet) color: #darkgoldenrod;
        	}        	
        }
        
		display "Activities" {
        	chart "Activities" type: pie {
        		data "Travail" value: Person count(each.current_activity.title = "Travail") color: #blue;
        		data "Course" value: Person count(each.current_activity.title = "Course") color: #red;
				data "Ecole" value: Person count(each.current_activity.title = "Ecole") color: #cyan;
        		data "Fac" value: Person count(each.current_activity.title = "Fac") color: #cyan;
				data "Promener chien" value: Person count(each.current_activity.title = "Promener chien") color: #green;
        		data "Sport" value: Person count(each.current_activity.title = "Sport") color: #green;
				data "accompagnement" value: Person count(each.current_activity.title = "accompagnement") color: #cyan;
        		data "retour maison" value: Person count(each.current_activity.title = "retour maison") color: #grey;
        	}        	
        }
        
        display "road" {
        	chart "Jammed roads" type: series {
        		data "Jammed roads" value: Road count(each.is_jammed = true) color: #black;
        	}
        }
        
        display "Road capacity" {
        	chart "Road capacity distribution" type: histogram {
        		data "]0;0.33]" value: Road count (each.current_capacity/each.max_capacity <= 0.33) color: #green ;
    			data "]0.33;0.66]" value: Road count ((each.current_capacity/each.max_capacity > 0.33) and (each.current_capacity/each.max_capacity <= 0.66)) color: #yellow ;
    			data "]0.67;1]" value: Road count ((each.current_capacity/each.max_capacity > 0.66) and (each.current_capacity/each.max_capacity <= 1.0)) color: #red ;
    			data "]1;*]" value: Road count (each.current_capacity/each.max_capacity > 0.1) color: #darkred;
        	}
        }
//		monitor "Time: " value: current_date;

	}
}

experiment "Display only" type: gui {
	/*
	 * Parameters
	 */
	parameter "Step" var: step category: "Simulation step in second" min:1.0 ;
	parameter "Simulated_days" var: simulated_days category: "Simulation days" min:1.0 #days;
	parameter "Pedestrians" var: feet_weight category: "modality" min:0.0;
	parameter "Bikes" var: bike_weight category: "modality" min:0.0;
	parameter "Cars" var: car_weight category: "modality" min:0.0;
	
	/*
	 * Interactive commands
	 */
	parameter "Person to select" var: Person_idx category: "Highlight path" min:0 ;
	parameter "Path to highlight" var: Path_idx category: "Highlight path" min:0;
	user_command "Display parameter" category: "Highlight path" color:#red {
		if Person_idx < length(Person) and Person_idx > -1 {
			ask Person[Person_idx] {do highlight_path(Path_idx);}
		}else{
			write "Person_idx is out of range ! Try again." color:#red;
		}
	}
	
	/*
	 * Outputs
	 */
	output {
		display main_window type: opengl {
			species Road;
			species Building;
			species Person;
			species Car;
		}
	}
}

experiment "Headless" type: gui {
	parameter "Step" var: step category: "Simulation step in second" min:1.0 ;
	parameter "Simulated_days" var: simulated_days category: "Simulation days" min:1.0 #days;
	parameter "Pedestrians" var: feet_weight category: "modality" min:0.0;
	parameter "Bikes" var: bike_weight category: "modality" min:0.0;
	parameter "Cars" var: car_weight category: "modality" min:0.0;
	
	output {
		
		display "empty" {
			
		}

	}

}
