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
	Road road;
	date entry_date;
	date leaving_date; 
	int lateness;
}