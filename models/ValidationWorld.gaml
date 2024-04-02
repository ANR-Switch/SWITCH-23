/**
* Name: World
* Based on the internal empty template. 
* Author: ohauterville
* Tags: 
* Commented
*/
model World

import "Logs/CSVLog.gaml"

import "Species/Map/ResidualFlow.gaml"

import "Species/Map/RoadsGraph.gaml"

import "Utilities/EventManager.gaml"


import "Logs/consolLog.gaml"
import "Logs/TxtLog.gaml"


//import "Logs/Logger.gaml"
//import "Species/Transports/TransportEdge.gaml"
//import "Utilities/Constants.gaml"
//import "Species/Map/Road.gaml"
//import "Utilities/Population_builder.gaml"

global skills: [scheduling] schedules: []{
	//FILES
	string dataset_path <- "../includes/agglo/";
	
 

	//shape_file shape_buildings <- shape_file(dataset_path + "buildings.shp");	
	shape_file shape_buildings <- shape_file("../includes/tests/INOUT.shp");


	//shape_file shape_roads_CT <- shape_file("../includes/tests/connected_comp/roads.shp")
	shape_file shape_roads_CT <- shape_file("../includes/tests/RoadImportance2/roads.shp");


	csv_file Matrices_OD <- csv_file("../includes/tests/RoadImportance1NC/Matrices_OD.csv",true);

	
	
	
	geometry shape <- envelope(shape_roads_CT);
	
	string gtfs_file <- dataset_path + "gtfs/";
	csv_file population <- csv_file("../includes/population/population.csv", ",", true);
	//int nbBoucle <- 7;
	
	//SIM	
	float step <- 3600 #seconds parameter: "Step"; //86400 for a day, 3600 for an hour. Step had to be a divider of 86400#s
	float simulated_days <- 1 #days parameter: "Simulated_days";
	float experiment_init_time;
	
	string path_algorithm <- #CHBidirectionalDijkstra    ;
	
	//general paramters	 
	date starting_date <- date([2022, 10, 12, 0, 0, 0]);
	
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

	int nb_event_managers <- 1;
	//EventManager event_manager;
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
	Logger csvlog;
	
	
	
	init {
		nb_trajet <- 0;
		pathNotFound <- 0;
		forcing <- 0;
		dayEnded <- 0;
		float sim_init_time <- machine_time;
		//date init_date <- (starting_date	 + (machine_time / 1000));

		//do normalize_modality();
		
		////Constants 
		create Constants; //constant file useful for other species
		create VehicleFactory;
		factory <- VehicleFactory[0];
		
		create ConsolLog;
		log <- ConsolLog[0];
		
		create CSVLog;
		csvlog <- CSVLog[0];
		//init
		do init_event_managers; //good to do first
		//do init_buildings;
		write ("init residual flow");
		do init_residual_flow(log,csvlog);
		do init_destination_list();
		loop i over:ResidualFlow{
			ask i {do init_OD;event_manager<-myself.EventManager[0];}
		}
		
	 	do init_roads;
//	 	
	 	do init_graphs; //should be done after roads and public transports

	 	
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
		event_manager <- EventManager[0];
	}
	
	
	

	
	
	
	action init_residual_flow(Logger l, Logger l2) {
		create ResidualFlow from: shape_buildings with: [
			id::int(read('id')),
			is_in::read('Type')='IN',
			coresponding_highway::read("correspond"),
			matrice_OD_daily::list<int>(read("OD_daily") split_with ";"),
			log::l,
			csvlog::l2,
			event_manager::EventManager[0]
		]{
			if is_in{
				matrice_OD<-[
					list<int>(read("OD_06") split_with ";"),
					list<int>(read("OD_69") split_with ";"),
					list<int>(read("OD_916") split_with ";"),
					list<int>(read("OD_1619") split_with ";"),
					list<int>(read("OD_190") split_with ";")
				];
				int i <-0;
				loop tmp_id over:[0,2,4,7]{
					list<int> tmp <- [];
					
					loop flow over:matrice_OD{
						add flow[i] to:tmp;
						
					}
					i <- i+1;
					add (tmp) to:map_OD at:ResidualFlow[tmp_id];
					
					
				}
				write("matrice_od : "+matrice_OD);
			}
			
		}
	}
	action init_destination_list{
		loop departure_point over:ResidualFlow{
			if departure_point.is_in{
				loop destination over:ResidualFlow{
					if !destination.is_in{
						add destination to:departure_point.destination_list;
					}
				}
			}
		}
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
		int act;
		
		loop e over: split_with(s, ";") {
			add int(e) div 10 to: r_list;
		}
    	 return r_list;
    }
    
    /*list<date> init_read_dates(string s) {
		list<date> r_list;
    	list<string> l1 <- split_with(replace(s, "'", ""), ";");
    	list<string> l2;
    	
    	loop e over: l1 {
    		l2 <- split_with(e, ":");

    		add date(starting_date.year, starting_date.month, starting_date.day, int(l2[0]), int(l2[1]), 0) to: r_list;
    	}
    	return r_list;
    }*/
	 
	 /*
	  * /!\
	  * 
	  * REFLEX
	  * 
	  * /!\
	  */
	 reflex {
	 
	 	loop r over:ResidualFlow{
	 		ask r {do create_flow;}
	 	}
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
		write "-> Current simulation date : " + get_current_date() +"\n";
		
		
		/*
		 * A la fin de la simu : 
		 */
		
	 	if (get_current_date()+step>=starting_date+24#h){//Person count(each.day_done) = length(Person) { //and TransportTrip count(each.alive) = 0 {
	 		
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
	 		
	 		ask log {do log('end_of_simulation_logs');}
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


experiment "Text only"{

	
	parameter "count forcing" var: countForcing category: "Counter";
	parameter "count no finded path" var: countPath category: "Counter";
	parameter "count people who didn't ended their day" var: countDayEnded category:"Counter";
	
	
	parameter "Show Path not found" var: verbosePathNotFound category: "Message";
	parameter "Show forcing message when road congested message" var: verboseRoadForcing category: "Message";
	parameter "Show activity message" var: verboseActivity category: "Message";
	parameter "Show people ending day" var: verboseEndDay category: "Message";
	parameter "Show travel message" var:verboseTravel category: "Message";
	
	user_command "Display parameter" category: "Highlight path" color:#red {
	}
}
