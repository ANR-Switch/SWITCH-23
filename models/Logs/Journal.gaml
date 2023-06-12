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
	
	action write_in_journal(int _idx, Vehicle _vehicle, string _road, string _road_topo_id, int _road_length, date _entry_date, date _leave_date, float _mean_speed, int _lateness) {
		create LoggedRoadEvent returns: event {
			trip_idx <- _idx;
			//activity_name <- myself.owner.personal_agenda.activities[_idx].title;
			activity_type <- myself.owner.activities[myself.owner.act_idx];
			vehicle <- _vehicle.name;
			vehicle_type <- string(species_of(_vehicle));
			road_gama_id <- _road;
			road_topo_id <- _road_topo_id;
			road_length <- _road_length;
			entry_date <- _entry_date;
			leave_date <- _leave_date;
			mean_speed <- _mean_speed;
			lateness <- _lateness;
		}
		
		add event[0] to: event_log;
	}
	
	action save(string file_path, bool _rewrite) {
		string agent_name <- owner.name;
		loop e over: event_log {
			ask e {
				save [agent_name, trip_idx, activity_type, vehicle_type, vehicle, road_gama_id, road_topo_id, road_length, entry_date, leave_date, mean_speed, lateness] to: file_path rewrite:_rewrite format:"csv";
			}
			//change bool so we do it only once
			if _rewrite {
				_rewrite <- false;
			}
		}
	}
}