/**
* Name: GTFSreader
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
* PT c'est Public Transports
*/



model GTFSreader

//import "../Species/Transports/TransportRoute.gaml"

import "../Species/Transports/TransportTrip.gaml"

//import "../Species/Transports/TransportStop.gaml"

species GTFSreader schedules: [] {
	
	//files
	string stops_file <- gtfs_file + "stops.txt";
	string trips_file <- gtfs_file + "trips.txt";
	string stop_times_file <- gtfs_file + "stop_times.txt";
	string routes_file <- gtfs_file + "routes.txt";
	string shapes_file <- gtfs_file + "shapes.txt";
	
	csv_file stops_csv <- csv_file(stops_file, ",", true);
	csv_file trips_csv <- csv_file(trips_file, ",", true);
	csv_file stop_times_csv <- csv_file(stop_times_file, ",", true);
	csv_file routes_csv <- csv_file(routes_file, ",", true);
	csv_file shapes_csv <- csv_file(shapes_file, ",", true);
	
	//maps
	map<string, TransportStop> stops_map;
	map<string, TransportRoute> routes_map;
	map<int, TransportTrip> trips_map;
	
	init {
		do create_stops;
		do create_routes;
		do create_trips;
		
		//do assign_shapes;
		do schedule_trips;
	}
	
	action create_stops {
		write "\nCreating the PT stops...";
				
		create TransportStop from: stops_csv with: [
			real_name::string(read("stop_name")),
			id::string(read("stop_id")),
			code::int(read("stop_code")), //empty ?
			location::point(to_GAMA_CRS({float(read("stop_lon")), float(read("stop_lat")),0.0},"EPSG:4326"))
		] {
			//create a map to find more quickly the corresponding stop 
			add id::self to: myself.stops_map;	
		}

		write "Done.";
	}
	
	action create_routes {
		write "\nCreating the PT routes..."; 
		
		//string ligneA_id <- "line:61"; //names in csv
		//string ligneB_id <- "line:69";
		
		create TransportRoute from: routes_csv with: [
			route_id::string(read("route_id")),
			short_name::string(read("route_short_name")),
			long_name::string(read("route_long_name")),
			type::int(read("route_type")),
			//color::rgb(#purple)
			color::rgb("#"+read("route_color"))
		]  {			
			//map
			add route_id::self to: myself.routes_map;	
		}

		write "Done.";
	}
	
	action create_trips {
		write "\nCreating the PT trips...";
		
		create TransportTrip from: trips_csv with: [
			route_id::read("route_id"),
			service_id::read("service_id"),
			trip_id::int(read("trip_id")),
			direction_id::int(read("direction_id")),
			shape_id::int(read("shape_id"))
		] {
			event_manager <- EventManager[0];
			//create a map to find more quickly the corresponding trip 		
			
			add trip_id::self to: myself.trips_map;	
		}
		
		write "Done.";
		
		// link data more consistently
		do assign_trips_stops_times;
	}
	
	action assign_trips_stops_times {
		/*
		 * 
		 * uses info of stop_times.txt
		 * column index : column name
		 * 0 : trip_id
		 * 1 : arrival_time
		 * 2 : departure_time
		 * 3 : stop_id
		 * 4 : pick_up_type
		 * 5 : drop off type
		 * 6 : stop sequence
		 * 7 : shape_dist_traveled
		 * 8 : time point 
		 * 9 : stop headsign
		 * 
		 */
		//write "Start building all the trips stop times...";
		matrix stop_times_mat <- stop_times_csv.contents;
		
		float t <- machine_time;
		loop _row over: rows_list(stop_times_mat) {
			
			ask trips_map[int(_row[0])] {
				if myself.stops_map[string(_row[3])] != nil {
					do add_stop(_row[2], myself.stops_map[string(_row[3])]);	
				}else{
					write "Unknown TransportStop: " + _row[3] + " it appear in TransportTrip: " + myself.trips_map[int(_row[0])].trip_id color:#red;
				}
			}
		}
		write "TransportTrips loaded in " + (machine_time-t)/1000 + " seconds.";
	}
	
	action assign_shapes {
		/*
		 * This method assign a shape to each trip, but we dont display that because there
		 * are too many trips, instead we display the routes.
		 * The thing is that one route has multiple shapes, we let the chance decide which one will be kept.
		 * 
		 * 0:route_id
		 * 1:shape_pt_lat
		 * 2:shape_pt_lon
		 * 3:shape_dist_traveled
		 * 4:shape_pt_sequence
		 */
		 
		//write "Creating shape of the TransportTrip...";
	
		//shapes
		map<int, list<point>> shape_map;
		int curr_id;
		list curr_shape <- [];
		
		//roads
		list<Road> roads <- Road where(each.car_track);
		list<int> done_shapes;
		//map<int, list<list<Road>>> bus_path_map;
		 
		//build shapes 
		loop _row over: rows_list(shapes_csv.contents) {
			if curr_id = int(_row[0]) {
				add point(to_GAMA_CRS({float(_row[2]), float(_row[1]),0.0},"EPSG:4326")) to: curr_shape;
			}else{
				add curr_id::curr_shape to: shape_map;
				
				curr_id <- int(_row[0]);
				curr_shape <- [];
			}
		}
				
		//assign shape to trip
		loop _t over: TransportTrip {
			_t.shape <- polyline(shape_map[_t.shape_id]);
			
			_t.transport_route <- routes_map[_t.route_id];
			
			//assign route's shape too 
			//there are several shapes for one route so we keep the longest
			//it is okay because it is just for display purposes.
			if length(polyline(shape_map[_t.shape_id]).points) > length(routes_map[_t.route_id].shape.points) {
				routes_map[_t.route_id].shape <- polyline(shape_map[_t.shape_id]);	
			}
		}
		write "Done.";
	}
	
	action schedule_trips {
		loop _t over: TransportTrip {
			ask _t {
				do schedule_departure_time;
			}
		}
	}
}