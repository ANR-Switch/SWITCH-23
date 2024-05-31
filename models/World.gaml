/**
* Name: World
* Based on the internal empty template. 
* Author: ohauterville
* Tags: 
* Commented
*/
model World

import "Species/Person.gaml"	
import "Species/Map/RoadsGraph.gaml"
import "Species/Map/Building.gaml"
import "Utilities/EventManager.gaml"
import "Species/Transports/TransportGraph.gaml"
import "Utilities/GTFS_reader.gaml"
import "Logs/consolLog.gaml"
import "Logs/TxtLog.gaml"

//import "Logs/Logger.gaml"
//import "Species/Transports/TransportEdge.gaml"
//import "Utilities/Constants.gaml"
//import "Species/Map/Road.gaml"
//import "Utilities/Population_builder.gaml"

global {
	//FILES
	string dataset_path <- "../includes/agglo/";
	
 
	//shape_file roads0_shape_file <- shape_file("../includes/roads/basicScenario/roadImportance3/roads.shp");


	shape_file shape_buildings <- shape_file(dataset_path + "bati.shp");
	
	
	
	shape_file shape_roads_CT <- shape_file("../includes/roads/speedLimitScenario/road3set1to110&3to50/roads.shp");
	//"C:\Users\flavi\Travail\Switch-23\includes\roads\speedLimitScenario\road3decrease1with30\road3decrease1with30.cpg"

	
	
	
	geometry shape <- envelope(shape_roads_CT);
	
	string gtfs_file <- dataset_path + "gtfs/";
	csv_file population <- csv_file("../includes/population/Pop.csv", ";", true);
	int nbBoucle <- 10;
	
	//SIM	
	float step <- 1200 #seconds parameter: "Step"; //86400 for a day, 3600 for an hour
	float simulated_days <- 1 #days parameter: "Simulated_days";
	float experiment_init_time;
	
	string path_algorithm <- #CHBidirectionalDijkstra    ;
	
	//general paramters	 
	date starting_date <- date([2023, 10, 12, 0, 0, 0]);
	
	//date sim_starting_date <- date([2023, 10, 12, 0, 0, 0]); //has to start at midnight! for activity.gaml init
	float cycle_timer <- machine_time;

	//modality
	/*
	 * ici on fixe les distributions de modalité
	 */
	float feet_weight <- 0.0 parameter: "Feet";
	float bike_weight <- 0.0 parameter: "Bike";
	float car_weight  <- 1.0 parameter: "Car";
	float public_transport_weight <- 0.0 parameter: "Public_Transport";
	list<float> weights <- [feet_weight,bike_weight,car_weight,public_transport_weight];
	//highlight path : useless now
	/*
	 * Ces paramètres servaient à selectionner un agent et un de ses trajet afin de le mettre en valeur dans le display, 
	 * mais ça a changé depuis, il faudra refaire la fonction
	 */
	int Person_idx <- 0 parameter: "Person_idx";
	int Path_idx <- 0 parameter: "Path_idx";

	int nb_event_managers <- 1;

	//TEST
	float _miliseconds <- 0.0;	
	int total_nb_paths <- 0;
	list<Road> forcedRoad;
	
	//Graphs
	TransportGraph public_transport_graph;
	
	int road_importance <- 6 const: true; //considers roads of importance less than or eq to this
	
	//Precalcul des chemins : en dev 
	bool save_matrix_as_csv <- false;
	string matrix_path <- "C:\\Users\\coohauterv\\git\\SWITCH-23\\includes\\matrices\\";
	matrix<int> car_shortest_paths;
	 
	 
	//buildings
	list<Building> working_buildings;
	list<Building> living_buildings;
	list<Building> leasure_buildings;
	list<Building> studying_buildings;
	list<Building> commercial_buildings;
	list<Building> administrative_buildings;
	list<Building> exterior_working_buildings;
	list<Building> trash_list;
	
	VehicleFactory factory;
	/*Consol*/Logger log;
	

	
	init {
		nb_trajet <- 0;
		pathNotFound <- 0;
		forcing <- 0;
		dayEnded <- 0;
		seed <- 42.0;
		float sim_init_time <- machine_time;
		//date init_date <- (starting_date	 + (machine_time / 1000));

		//do normalize_modality();
		
		////Constants 
		create Constants; //constant file useful for other species
		create VehicleFactory;
		factory <- VehicleFactory[0];
		
		create ConsolLog;
		log <- ConsolLog[0];
		
		//init
		do init_event_managers; //good to do first
		do init_buildings;
		//do init_building_INOUT;
	 	do init_roads;
//	 	
	 	do init_graphs; //should be done after roads and public transports
//	 	
//	 	do init_delays;
//	 	
	 	do init_persons_csv;
	 	
		//logger should be created after the other species
		if Constants[0].log_journals or Constants[0].log_roads or Constants[0].log_traffic {
			/*create Logger;
			Logger[0].event_manager <- EventManager[0];	*/
			write "\nLog options activated...";
		}else{
			write "\nAll logging options are turned off." color: #orange;
		}
		
		write "Simulation is ready. In " + (machine_time - sim_init_time)/1000.0 + " seconds." ;
	}
	
	action init_delays{
		loop i over:Road{
			ask i {do init_delay;}
		}
	}
	
	action init_event_managers{
		create EventManager number: nb_event_managers;
		current_date <- starting_date;
	}
	
	action init_persons_csv {
		//create the persons
		write "\nPersons...";
		float t1 <- machine_time;
		
		loop i from:0 to: nbBoucle-1 {
		
			create Person from: population with: [
				/*first_name::read("nom"),
				age::int(read("age")),
				genre::read("genre"),
				professional_activity::int(read("activite_pro")),
				income::int(read("revenu")),
				study_level::int(read("etudes"))*/
				activities::init_read_activities(string(read("activities"))),//init_read_activities(read("activities"))
				starting_dates::init_read_dates(string(read("departs")))//init_read_dates(string(read("depart")))
			]{
				event_manager <- EventManager[0];
				self.log <- myself.log;
					
	//			//buildings
				living_building <- select_building(living_buildings);
				location <- any_location_in(living_building);
				current_building <- living_building;
				working_building <- select_building(working_buildings);
				administrative_building <- select_building(administrative_buildings);
				studying_building <- select_building(studying_buildings);
				commercial_building <- select_building(commercial_buildings);
				leasure_building <- select_building(leasure_buildings);
				
				
				
	//			//vehicle
				
				do choose_vehicles(weights,factory);
	//			//activities
				do register_activities; //after link to eventmanager
			}			
		}		
		write "There are " + length(Person) + " Persons loaded in " + (machine_time-t1)/1000.0 + " seconds.";
	}
	
	action init_buildings {
	 	write "\nBuildings...";
	 	float t1 <- machine_time;
		create Building from: shape_buildings with: [
			type::int(read("type")),
			real_name::read("name"),
			db_id::read("osm_id")
		]{
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
				default {
					color <- #yellow;
				}	
			}
		}
		write "There are " + length(Building) + " Buildings loaded in " + (machine_time-t1)/1000.0 + " seconds.";
		write "Living buildings: " + length(living_buildings) ;
		write "Working buildings: " + length(working_buildings) ;
		write "Studying buildings: " + length(studying_buildings) ;
		write "Commercial buildings: " + length(commercial_buildings) ;
		write "Administrative buildings: " + length(administrative_buildings) ;
		write "Leasure buildings: " + length(leasure_buildings) ;
		
	 }
	 
	 action init_roads {
	 	write "\nRoads...";
	 	float t1 <- machine_time;
	 	//car roads
		create Road from: shape_roads_CT with: [lanes::int(read("NB_VOIES")), 
											max_speed::float(read("VIT_MOY_VL")),
											oneway::string(read("SENS")),
											topo_id::string(read("ID")),
											allowed_vehicles::string(read("VEHICULES")),
											importance::int(read("IMPORTANCE")),
											nature::string(read("NATURE")),
											event_manager::EventManager[0]
		] {
			
			if Constants[0].double_the_roads {
				//double les routes si ce n'est pas déjà fait dans la BD
				if oneway = "Double sens" {	
					create Road with: [
						lanes::self.lanes,
						max_speed::self.max_speed,
						oneway::self.oneway,
						topo_id::self.topo_id,
						allowed_vehicles::self.allowed_vehicles,
						importance::self.importance,
						event_manager::EventManager[0],
						shape::polyline(reverse(self.shape.points))
					];	
				}
			}
			if oneway = "Sens inverse" {				
				shape <- polyline(reverse(shape.points));
			}
			self.log<-myself.log;
			//do log_capacity();
		}
		write "There are " + length(Road) + " Roads loaded in " + (machine_time-t1)/1000.0 + " seconds.";
		write "" + length(Road where each.had_to_increase_capacity) + " roads had to increase their maximum capacity." color:#orange;
		 //TEST
//		 loop i over: Road where each.car_track {
//		 	add i::i.max_capacity to: road_distribution;
//		 }
	 }
	 
	 action init_graphs {
	 	write "\nGraphs...";
	 	float t1 <- machine_time;
	 	list<Road> road_subset;
	 	list<Road> cleaned_road;
	 	map<Road, float> road_weights_map;
	 	
	 	cleaned_road <- clean_network(Road where (true),1.0,false,true);
	 	//save missed_start format:shp to:'debug/missed_start.shp';
	 	
	 	
	 	
	 	
	 	//feet 
	 	road_subset <- Road where (each.max_speed < 60/3.6);
	 	road_weights_map <- road_subset as_map (each:: each.shape.perimeter);
	 	feet_road_graph <-  (as_edge_graph(road_subset) with_weights road_weights_map);
	 	feet_road_graph <- main_connected_component(feet_road_graph);
	 	write "Pedestrians can use " + length(road_subset) + " road segments.";
	 	
	 	//bike
	 	/*
	 	 * for now they use the same as the pedestrians 
	 	road_subset <- Road where (each.max_speed < 70/3.6);
	 	road_weights_map <- road_subset as_map (each:: (each.shape.perimeter));
	 	bike_road_graph <- as_edge_graph(road_subset) with_weights road_weights_map;
	 	* 
	 	*/
	 	bike_road_graph <- feet_road_graph;
	 	write "Cyclists can use " + length(road_subset) + " road segments.";
	 	
	 	//car
	 	road_subset <- cleaned_road where (each.car_track and each.importance <= road_importance);
	 	//road_subset <- Road where (each.car_track and each.importance <= road_importance);
	 	road_weights_map <- road_subset as_map (each:: (each.compute_time()));
	 	car_road_graph <- as_edge_graph(road_subset) with_weights road_weights_map;
	 	//car_road_graph <- car_road_graph with_shortest_path_algorithm path_algorithm ;
	 	car_road_graph <- directed(car_road_graph);
	 	list<Road> list_road;
	 	loop edge over: car_road_graph{
	 		add edge to:list_road;
	 	}
	 	save list_road format:shp to:"debug/car_road_graph.shp" ;
	 	
	 	//estimate for info
		int compo <- length(connected_components_of(car_road_graph));
		if compo != 1 {
			write "There are " + compo + " components of the car-road graph before keeping the main one" color: #orange;
		}
		//
	 	
	 	car_road_graph <- main_connected_component(car_road_graph);

	 	write "Cars can use " + length(car_road_graph) + " road segments.";
	 	
	 	if save_matrix_as_csv{
	 		try {
	 			car_road_graph <- load_shortest_paths(car_road_graph, matrix(csv_file(matrix_path+"car_road_matrix" + string(road_importance) + ".csv")));
	 		}
	 		catch {
	 			car_shortest_paths <- save_matrix_from_graph(car_road_graph, matrix_path+"car_road_matrix" + string(road_importance) + ".csv");
	 			car_road_graph <- load_shortest_paths(car_road_graph, matrix(csv_file(matrix_path+"car_road_matrix" + string(road_importance) + ".csv")));
	 		}
	 	}
	 	
	 	if Constants[0].load_public_transports {
		 	//Public transports
		 	
		 	create GTFSreader; 
		 	
		 	ask GTFSreader[0] {
		 		do assign_shapes;
		 	}
		 	
		 	create TransportGraph returns: _graph {
		 		event_manager <- EventManager[0];
		 	}
		 	
		 	public_transport_graph <- _graph[0];	
		 }else{
		 	write "The public transport option is not on. You can turn it on in the Constants file." color:#orange;
		 }
	 	
	 	write "Graphs created in " + (machine_time-t1)/1000.0 + " seconds.";
	 }
	 
	 matrix<int> save_matrix_from_graph(graph gr, string file_name){
	 	/*
	 	 * Cette fonction sert à précalculer les plus courts chemins
	 	 */
	 	matrix<int> mat;
	 	
 		write "Saving the graph shortest paths...";
 		float t <- machine_time;
 		mat <- all_pairs_shortest_path(gr);
 		//csv_file _file <- csv_file(name, mat);
 		save mat to:file_name format:"csv" rewrite:true header:false ;
 		write "Done in " + (machine_time-t)/1000.0 + " seconds.";
	 	
	 	return mat;
	 }
	 
	 action normalize_modality {
	 	/*
	 	 * Cette fonction normalise les parts modales pour que la somme soit 1.0
	 	  */
	 	float sum <- feet_weight + bike_weight + car_weight + public_transport_weight;
	 	feet_weight <- feet_weight / sum ;
	 	bike_weight <- bike_weight / sum ;
	 	car_weight <- car_weight / sum ;
	 	public_transport_weight <- public_transport_weight / sum;
	 }
	

	list<int> init_read_activities(string s) {
		list<int> r_list;
		s <- (replace(s,'[',''));
		s <- (replace(s,']',''));
		
		loop e over: split_with(s, ",") {
			add int(e) div 10 to: r_list;
		}
    	 return r_list;
    }
    
    list<date> init_read_dates(string s) {
		list<date> r_list;
		s <- (replace(s,'[',''));
		s <- (replace(s,']',''));
    	list<string> l1 <- split_with(replace(s, "'", ""), ",");
    	list<string> l2;
    	
    	loop e over: l1 {
    		l2 <- split_with(e, ":");

    		add date(starting_date.year, starting_date.month, starting_date.day, int(l2[0]), int(l2[1]), 0) to: r_list;
    	}
    	return r_list;
    }
	 
	 /*
	  * /!\
	  * 
	  * REFLEX
	  * 
	  * /!\
	  */
	 reflex { 
		if cycle = 0 {
			//save the starting time for information
			experiment_init_time <- machine_time;
		}
		

		
		
		write "\n-> The cycle took " + (machine_time-cycle_timer)/1000 + " seconds to simulate " + step + " seconds.";
		if(machine_time-cycle_timer != 0)
		{
			write "-> Sim_time/Real_time ratio: " + int((1000*step)/(machine_time-cycle_timer)) ;
		}
		cycle_timer <- machine_time;
		write "-> Current simulation date : " + current_date add_seconds(-step) + "\n";
		
		ask log {do write_log();}
		write "\n-> log written in : " + (machine_time - experiment_init_time)/1000.0 + " seconds.\n" color:#green;
	 		
	 	if (EventManager[0].size = 0){
	 		
	 		loop a over:Person{
		 		if !a.day_done{
		 			ask a{
		 				//do start_motion();
		 				do later the_action:"travel_not_end" at:date([2023, 10, 12, 23, 59, 59])+15#h ;
		 				if a.is_moving_chart{
		 					//write current_vehicle.current_road color:#red;
		 				}
		 				
		 			}
		 		}
		 	}
	 	}
		
		/*
		 * A la fin de la simu : 
		 */
		
	 	if (current_date>=starting_date+31#h){//Person count(each.day_done) = length(Person) { //and TransportTrip count(each.alive) = 0 {
	 		write "\n-> The experiment took: " + (machine_time - experiment_init_time)/1000.0 + " seconds.\n" color:#green;
	 		loop i over:Road{
	 			if (i.self_forced>0){
	 				add i to: forcedRoad;		
	 			}
	 			if(i.fail>0){
	 				write i.topo_id+" failed : "+i.fail;
	 			}
	 			try{
	 				//ask i {do log_frenquency();}
	 			}
	 			
	 		}
	 		//save forcedRoad format:shp to:'forcedRoad.shp';
	 		//write "missed point : "+missed_point;
	 		//save missed_start format:shp to:'debug/missed_start.shp';
	 		//save missed_dest format:shp to:'debug/missed_dest.shp';
	 		save path_list format:shp to:'debug/path_list.shp';
	 		//save missed_path_influence format:shp to:'debug/missed_path_influence.shp';
	 		
	 		loop r over:Road{
	 			ask r{do log_end;}
	 		}
	 		
	 		
	 		write "\n-> log written in : " + (machine_time - experiment_init_time)/1000.0 + " seconds.\n" color:#green;
	 		//ask log {do log('frequentation entre empalot et rangueil : '+day_frequentation_Empalot_Rangeuil);}
	 		//LOGS
	 		/*if !empty(Logger) {
	 			write "Logging, please wait...";
		 		ask Logger[0] {
		 			do save_real_time_logs;
		 			do save_journal_logs;
		 		}	
		 	}*/
		 	
		 	
//		 	write (""+msg_sent+" message has been sent");
//		 	write (""+msg_receive+" message has been receive");
//		 	write (""+msg_accept+" message has been accept");
	 		do pause;
	 	}
	 }
}


experiment "Display & Graphs" type: gui {
	/*
	 * Parameters
	 */
	parameter "Step" var: step category: "Simulation step in second" min:60.0 ;
//	parameter "Simulated_days" var: simulated_days category: "Simulation days" min:1.0 #days;
	parameter "Pedestrians" var: feet_weight category: "modality" min:0.0;
	parameter "Bikes" var: bike_weight category: "modality" min:0.0;
	parameter "Cars" var: car_weight category: "modality" min:0.0;
	parameter "Public_Transport" var: public_transport_weight category: "modality" min:0.0;
	
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
			species Road refresh:false;
			species TransportStop refresh:false;
			species TransportRoute refresh:false;
			//species Building refresh:false;
			species Person;
			species Car;
			species Bus;
			species Metro;
			species Teleo;
		}
		
//		display "chart_display" {
//	        chart "Mean per-travel-lateness" type: histogram {
//	        	datalist  (distribution_of(Person collect (each.total_lateness/(length(each.personal_agenda.activities))),4,0, Person max_of(each.total_lateness/(length(each.personal_agenda.activities)))) at "legend") 
//	            value:(distribution_of(Person collect (each.total_lateness/(length(each.personal_agenda.activities))),4,0,Person max_of(each.total_lateness/(length(each.personal_agenda.activities)))) at "values");      
//	        } 
//        }
        
        display "Persons moving" {
        	chart "Moving persons" x_tick_unit: 10 x_serie_labels: (""+current_date.hour+"h"+current_date.minute) type: series {
        		data "Persons moving" value: Person count(each.is_moving_chart = true) color:#black;
        	}
        } 
        
        display "Part modales" {
        	chart "Parts modales" type: pie {
        		data "PublicTransport" value: Person count(each.is_moving_chart and species(each.current_vehicle)=PublicTransportCard) color: #pink;
        		data "Cars" value: Person count(each.is_moving_chart and species(each.current_vehicle)=Car) color: #yellow;
        		data "Bikes" value: Person count(each.is_moving_chart and species(each.current_vehicle)= Bike) color: #limegreen;
        		data "Pedestrians" value: Person count(each.is_moving_chart and species(each.current_vehicle)= Feet) color: #darkgoldenrod;
        	}        	
        }
        
		/*display "Activities" {
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
        }*/
        
        display "road" {
        	chart "Jammed roads" x_tick_unit: 10 x_serie_labels: (""+current_date.hour+"h"+current_date.minute) type: series {
        		data "Jammed roads" value: Road count(each.is_jammed = true) color: #black;
        	}
        }
        
        display "Road capacity" {
        	chart "Road capacity distribution" type: histogram {
        		data "]0;0.33]" value: Road count (each.current_capacity/each.max_capacity <= 0.33) color: #green ;
    			data "]0.33;0.66]" value: Road count ((each.current_capacity/each.max_capacity > 0.33) and (each.current_capacity/each.max_capacity <= 0.66)) color: #orange ;
    			data "]0.67;1]" value: Road count ((each.current_capacity/each.max_capacity > 0.66) and (each.current_capacity/each.max_capacity <= 1.0)) color: #red ;
    			data "]1;*]" value: Road count (each.current_capacity/each.max_capacity > 1.0) color: #darkred;
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
	parameter "Public_Transport" var: public_transport_weight category: "modality" min:0.0;
	
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
//			species TransportStop refresh: false;
//			species TransportRoute refresh: false;
//			species TransportEdge;
			
//			species Building refresh:false;
//			species Road refresh:false;
			
//			species Person;
//			species Car;
//			species Bike;
			
//			species Bus;
//			species Metro;
//			species Tramway;
//			species Teleo;
			
			overlay right: "Date: " + current_date  color: #orange;
		}
	}
}
experiment "Text only"{
	parameter "Person to select" var: Person_idx category: "Highlight path" min:0 ;
	parameter "Path to highlight" var: Path_idx category: "Highlight path" min:0;
	
	parameter "count forcing" var: countForcing category: "Counter";
	parameter "count no finded path" var: countPath category: "Counter";
	parameter "count people who didn't ended their day" var: countDayEnded category:"Counter";
	
	
	parameter "Show Path not found" var: verbosePathNotFound category: "Message";
	parameter "Show forcing message when road congested message" var: verboseRoadForcing category: "Message";
	parameter "Show activity message" var: verboseActivity category: "Message";
	parameter "Show people ending day" var: verboseEndDay category: "Message";
	parameter "Show travel message" var:verboseTravel category: "Message";
	
	user_command "Display parameter" category: "Highlight path" color:#red {
		if Person_idx < length(Person) and Person_idx > -1 {
			ask Person[Person_idx] {do highlight_path(Path_idx);}
		}else{
			write "Person_idx is out of range ! Try again." color:#red;
		}
	}
}
