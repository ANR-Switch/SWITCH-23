/**
* Name: LoggedRoadEvent
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

/*
 * This is just a structure to store info for the output CSV
 */

model LoggedRoadEvent

import "../Species/Map/Road.gaml"

species LoggedRoadEvent schedules: [] {
	int trip_idx;
	int activity_type;
	string vehicle;
	string vehicle_type;
	string road_gama_id;
	string road_topo_id;
	int road_length;
	date entry_date;
	date leave_date; 
	float mean_speed;
	int lateness;
}