/**
* Name: GTFSreader
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model GTFSreader

import "../Species/Map/TransportTrip.gaml"

import "../Species/Map/TransportStop.gaml"

/* Insert your model definition here */

species GTFSreader schedules: [] {
	string file_path <- "../../includes/Toulouse/gtfs_tisseo/";
	
	//files
	string stops_file <- file_path + "stops.txt";
	string trips_file <- file_path + "trips.txt";
	string stop_times_file <- file_path + "stop_times.txt";
	string routes_file <- file_path + "routes.txt";
	
	csv_file stops_csv <- csv_file(stops_file, ",", true);
	csv_file trips_csv <- csv_file(trips_file, ",", true);
	csv_file stop_times_csv <- csv_file(stop_times_file, ",", true);
	csv_file routes_csv <- csv_file(routes_file, ",", true);
	
	//matrix
//	matrix stops <- stops_csv.contents;
//	matrix routes <- routes_csv.contents;
	
	//maps
	map<string, int> stops_map;
	map<int, int> trips_map;
	
	init {
		do create_stops;
		do create_trips;
	}
	
	action create_stops {
		write "Creating the stops...";
		create TransportStop from: stops_csv with: [
			real_name::read("stop_name"),
			id::string(read("stop_id")),
			code::int(read("stop_code")),
			location::point(to_GAMA_CRS(point(float(read("stop_lat")), float(read("stop_lon")))))
		];
		
		//create a map to find more quickly the corresponding stop 
		int index_in_list <- 0;
		loop _stop over: TransportStop {
			add _stop.id::index_in_list to: stops_map;	
			index_in_list <- index_in_list + 1;	
		}
		write "Done.";
	}
	
	action create_trips {
		write "Creating the trips...";
		create TransportTrip from: trips_csv with: [
			route_id::read("route_id"),
			service_id::read("service_id"),
			trip_id::int(read("trip_id")),
			direction_id::int(read("direction_id")),
			shape_id::int(read("shape_id"))
		];
		
		//create a map to find more quickly the corresponding trip 
		
		int index_in_list <- 0;
		loop _trip over: TransportTrip {
			add _trip.trip_id::index_in_list to: trips_map;	
			index_in_list <- index_in_list + 1;	
		}
		write "Done.";
		
		// link dta more consistently
		do link_trips_name;
		do link_trips_stops_times;
	}
	
	action link_trips_stops_times {
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
		write "Start building all the trips stop times...";
		matrix stop_times_mat <- stop_times_csv.contents;
		int prev_trip <- -1; //this is just used for optimization
		int curr_trip;
		int trip_idx;
		int stop_idx;
		
		float t <- machine_time;
		loop _row over: rows_list(stop_times_mat) {
			curr_trip <- int(_row[0]);
			
			trip_idx <- trips_map[curr_trip];
			stop_idx <- stops_map[string(_row[3])];
			
			ask TransportTrip[trip_idx] {
				do add_stop(_row[2], TransportStop[stop_idx]);
			}
		}
		write "TransportTrips loaded in " + (machine_time-t)/1000 + " seconds.";
	}
	
	action link_trips_name {
		/*
		 * 0 : route_id
		 * 3 : route_long_name
		 * 6 : route_type
		 */
		 
		int trip_idx;
		 
		loop _row over: rows_list(routes_csv.contents) {
			trip_idx <- trips_map[int(_row[0])];
			TransportTrip[trip_idx].route_long_name <- string(_row[3]);
			TransportTrip[trip_idx].route_type <- int(_row[6]);			
		}
	}
}