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
	string activity_name;
	string vehicle;
	string road;
	int road_length;
	date entry_date;
	date leave_date; 
	float mean_speed;
	int lateness;
}