/**
* Name: Logger
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Logger

import "../Species/Person.gaml"

/* observer */

species Logger skills: [scheduling] {
	//files
	string output_path <- "C:\\Users\\coohauterv\\git\\SWITCH-23\\output\\";
	
	string journals_output_file <- "journals_person" + string(length(Person)) + "_modality" + string(int(10*car_weight)) + string(int(10*bike_weight)) + string(int(10*feet_weight)) + ".csv";
	string roads_output_file <- "roads_person" + string(length(Person)) + "_modality" + string(int(10*car_weight)) + string(int(10*bike_weight)) + string(int(10*feet_weight)) + "_step" + string(int(step)) + ".csv";
	string traffic_output_file <- "traffic_person" + string(length(Person)) + "_modality" + string(int(10*car_weight)) + string(int(10*bike_weight)) + string(int(10*feet_weight)) + "_step" + string(int(step)) + ".csv";
	
	//options
	bool log_roads_bool <- Constants[0].log_roads;
	bool log_journals_bool <- Constants[0].log_journals;
	bool log_traffic_bool <- Constants[0].log_traffic;
	
	//files
	string roads_file <- output_path + roads_output_file ;
	string traffic_file <- output_path + traffic_output_file ;
	string journals_file <- output_path + journals_output_file ;
	
	//msg
	list full_road_msg_csv <- [];
	list full_traffic_msg <- [];
	
	//utilities
	string d;
	string h;
	string m;
	string s;

	
	action log_roads{
		float ratio;
		list new_msg <- [];
		
		loop r over: Road {
			ask r {
				ratio <- get_capacity_ratio();
			}
			add ratio to: new_msg ;				
		}
		add get_date_in_string() to: new_msg;
//		add get_current_date() to: new_msg;
		
		add new_msg to: full_road_msg_csv;
	}
	
	action log_traffic {
		int cars <- Person count(each.is_moving_chart and species(each.current_vehicle)=Car);
		int bikes <- Person count(each.is_moving_chart and species(each.current_vehicle)=Bike);
		int feet <- Person count(each.is_moving_chart and species(each.current_vehicle)=Feet);
		add [cars, bikes, feet, get_date_in_string()] to: full_traffic_msg;
//		add [cars, bikes, feet, get_current_date()] to: full_traffic_msg;
	}
	
	action save_journal_logs {
		if log_journals_bool {
			float t1 <- machine_time;
			write "Writing the journals output file in: " + journals_file;
			write "It can take a while...";
			bool erased <- false;
			
			loop p over: Person  {
				write "Saving " + p.name + "...";
				if !erased {
					ask p.journal {
						do save(myself.journals_file, true);
					}
					erased <- true;	
				}else{
					ask p.journal {
						do save(myself.journals_file, false);
					}
				}
			}
			write "Done in " + (machine_time-t1)/1000 + "s.";	
		}
	}
	
	action save_real_time_logs {
		//roads
		if log_roads_bool {
			write "Writing the roads output file in: " + roads_file;
			bool erased <- false;
			loop _line over: full_road_msg_csv {
				if !erased {
					//make header
					list header <- [];
					loop r over: Road {
						add r.name to: header;
					}
					add "Date" to: header;
					save header to: roads_file format:"csv" rewrite:true header:false;
					
					//write line properly
					list to_write <- [];
					loop capacity over: _line {
						add capacity to: to_write;
					} 
					save to_write to: roads_file format:"csv" rewrite:false;
					erased <- true;
				}else{
					//write line properly
					list to_write <- [];
					loop capacity over: _line {
						add capacity to: to_write;
					} 
					save to_write to: roads_file format:"csv" rewrite:false;
				}
			}
			write "Done.";
		}
		//traffic
		if log_traffic_bool {
			write "Writing the traffic output file in: " + traffic_file;
			bool erased <- false;
			loop line over: full_traffic_msg {
				if !erased {
					save ["Cars", "Bikes", "Pedestrians", "Date"] to: traffic_file format:"csv" rewrite:true header:false;
					save [line[0], line[1], line[2], line[3]] to: traffic_file format:"csv" rewrite:false;	
					erased <- true;
				}else{
					save [line[0], line[1], line[2], line[3]] to: traffic_file format:"csv" rewrite:false;	
				}
			}
			write "Done.";
		}
	}
	
	string get_date_in_string {
		if get_current_date().day < 10 {
			d <- "0" + string(get_current_date().day);
		}else{
			d <- string(get_current_date().day);
		}
		if get_current_date().hour < 10 {
			h <- "0" + string(get_current_date().hour);
		}else{
			h <- string(get_current_date().hour);
		}
		if get_current_date().minute < 10 {
			m <- "0" + string(get_current_date().minute);
		}else{
			m <- string(get_current_date().minute);
		}
		if get_current_date().second < 10 {
			s <- "0" + string(get_current_date().second);
		}else{
			s <- string(get_current_date().second);
		}
		return d+ "-" + h + ":" + m + ":" + s;
	}
	
	reflex log {
		if log_roads_bool{
			do log_roads();
		}
		if log_traffic_bool {
			do log_traffic();
		}
	}
}