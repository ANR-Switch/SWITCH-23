/**
* Name: journal
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Journal

import "LoggedRoadEvent.gaml"

species Journal schedules: [] {
	Person owner;
	list<LoggedRoadEvent> event_log <- [];
	
	action write_in_journal(int _idx, string _vehicle_name, Road _road, date _entry_date, date _leaving_date, int _lateness) {
		create LoggedRoadEvent returns: event {
			trip_idx <- _idx;
			activity_name <- myself.owner.personal_agenda.activities[_idx].title;
			vehicle <- _vehicle_name;
			road <- _road;
			entry_date <- _entry_date;
			leaving_date <- _leaving_date;
			lateness <- _lateness;
		}
		
		add event[0] to: event_log;
	}
	
	action write_final_log {
		
	}
}