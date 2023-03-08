/**
* Name: activity
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model activity

import "../Map/Building.gaml"

species Activity schedules: [] {
	int id;
	string title;
	int priority_level;
	int type;
	int starting_minute;
	date starting_date;
	int duration;
	point activity_location;
	
	action set_starting_date (date d) {
		starting_date <- d add_minutes starting_minute;
	}
	
	action choose_location (list<Building> living_buildings, list<Building> working_buildings){
		if type=0 {
			activity_location <- any_location_in(one_of(living_buildings));
		}else{
			activity_location <- any_location_in(one_of(working_buildings));
		}
	}
}
