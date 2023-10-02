/**
* Name: Person
* Based on the internal empty template. 
* Author: coohauterv
* Tags:
* Commented
*/


model Person

import "Vehicles/PublicTransportCard.gaml"

import "../Logs/Journal.gaml"

import "../Utilities/Constants.gaml"

import "Vehicles/Feet.gaml"

import "Vehicles/Bike.gaml"

import "Vehicles/Car.gaml"

import "../Utilities/EventManager.gaml"

import "Activities/Agenda.gaml"


species Person skills: [scheduling] schedules: [] {
	string first_name; //already built in attribute
	string genre;
	int age;
	int professional_activity;
	int income;
	int study_level;
	list<int> profile;
	//Agenda personal_agenda;
	
	//activities
	list<int> activities;
	list<date> starting_dates;
	int act_idx <- -1; 
	point current_destination; 
	
	//buildings
	Building current_building;
	Building next_building;
	Building living_building;
	Building working_building;
	Building commercial_building;
	Building studying_building;
	Building leasure_building;
	Building administrative_building;
	//bool is_going_in_ext_zone <- false; //used for display
	
	//
	list<string> journal_str;
	//Journal journal;
	bool day_done <- false; 
	
	float walking_speed <- 1.39 ; //#meter / #second ;
	rgb color <- #black;
	Vehicle current_vehicle;
	list<Vehicle> vehicles <- [];
	Feet my_feet;
	
	//output display
	bool is_moving_chart <- false; //used for display
	
	init {
		create Feet returns: f;
	  	my_feet <- f[0];
	}

	
	Building select_building (list<Building> l){
		return one_of(l);
	}    

    action register_activities {
    	if !empty(activities) and !empty(starting_dates){
	    	assert length(activities) = length(starting_dates);
	    	date d;
	    	//loop i from:0 to: length(activities)-1 {
    		d <- starting_dates[0] add_minutes rnd(-floor(Constants[0].starting_time_randomiser/2), floor(Constants[0].starting_time_randomiser/2));
	  		do later the_action: "start_activity" at: d ;
	    	//}	
	    }
    }
    
    action start_activity {    	
    	assert !empty(vehicles) warning: true;
    	act_idx <- act_idx + 1;
    	//write get_current_date() + ": " + name + " starts activity" + act_idx color:#green;

		switch int(activities[act_idx]){
			match 0 {
				current_destination <- any_location_in(living_building);
				next_building <- living_building;
			}
			match 1 {
//				if flip(Constants[0].ratio_exterior_workers) and (species(current_vehicle) = Car){
//					current_destination <- any_location_in(exterior_working_building);
//					next_building <- exterior_working_building;
//					is_going_in_ext_zone <- true;
//				}else{
					current_destination <- any_location_in(working_building);
					next_building <- working_building;
				//}
				
			}
			match 2 {
				current_destination <- any_location_in(studying_building);
				next_building <- studying_building;
			}
			match 3 {
				current_destination <- any_location_in(commercial_building);
				next_building <- commercial_building;
			}
			match 4 {
				current_destination <- any_location_in(administrative_building); 
			}
			match 5 {
				current_destination <- any_location_in(leasure_building);
				next_building <- leasure_building;
			}
			match 6 {
				current_destination <- any_location_in(studying_building);
				next_building <- studying_building;
			}
			default {
				write "Weird activity !" color: #red;
			}
		}
    	
		if location != current_destination {
			do choose_current_vehicle;
	
//			if species(current_vehicle) = Car { //TRYING without walk_to
//				do walk_to(current_vehicle.location);
//			}else{
				do start_motion;	
//			}
		}else{
			write name + " is already at its destination. It will do its activity directly.";
			do end_motion;
		}
    }
        
    
    action start_motion{
//    	write get_current_date() + ": " + name + " takes vehicle: " + current_vehicle.name + " to do: " + current_activity.title;
    	is_moving_chart <- true;
    	total_nb_paths <- total_nb_paths + 1; //TEST, to remove later
    	ask current_vehicle{
    		if species(myself.current_vehicle) != PublicTransportCard {
    			do add_passenger(myself);	
    		}
			do goto(myself.current_destination);
		}
    }
    
    action end_motion {
//    	location <- current_destination;
    	current_building <- next_building;
    	color <- current_building.color;
    	is_moving_chart <- false;
    	  
    	if species(current_vehicle) != PublicTransportCard {  	
	    	ask current_vehicle{
	    		do remove_passenger(myself);
	    	}	
	    }

    	
    	//register next activity
    	if act_idx + 1 = length(activities) {
			//daydone
			//write get_current_date() + ": " + name + " ended its day correctly.";
			day_done <- true;
		}else if act_idx + 1 < length(activities){
				date d <- starting_dates[act_idx+1] add_minutes rnd(-floor(Constants[0].starting_time_randomiser/2), floor(Constants[0].starting_time_randomiser/2));
			if get_current_date() < d {
    	  		do later the_action: "start_activity" at: d ;
			}else{
				do later the_action: "start_activity" at: get_current_date() add_seconds 1;
			}
		}  	
    }
    
    action walk_to(point p) {
    	/*
    	 * Je soupconne cette fonction de ralentir la simulation, 
    	 * je ne l'utilise pas pour l'instant
    	 */
    	//write "test, fct walk to is being called";
    	color <- #darkgoldenrod;
    	float d <- distance_to(location, p) #meter ;
    	
    	if d > walking_speed {
    		//move
    		//set vehicle to feet
    		float angle <- atan2(p.y - location.y, p.x - location.x);
    		location <- point(location.x + walking_speed * cos(angle), location.y + walking_speed * sin(angle));
    		
    		do later the_action: "walk_to" with_arguments: map("p"::p) at:get_current_date() add_seconds 1;
    	}else{
    		//motion over
    		bool found <- false;
    		location <- p;
    		
    		/*
    		 * here we have to find out what action we were supposed to perform
    		 * we do it by checking what was our destination in the first place
    		 * only two cases should appear : 
    		 * either we joined our current_vehicle
    		 * either we walked to our activity location
    		 */
    		if location = current_destination {
    			found <- true;
    			do end_motion;
    		}else if location = current_vehicle.location {
				found <- true;
				do start_motion;
			}else{
				write get_current_date() + ": Something is wrong with the fct walk_to() of: " + name color:#red;  			
    		}
    	} 	 	
    }
    
    action choose_current_vehicle {
    	/*
    	 * Cette fct est uen ébauche d'un choix modal. A faire plus tard
    	 * Si fct_on <- false, on ne fait pas de choix modal
    	 */
    	bool fct_on <- false;
    	if fct_on {
	    	path planned_path;
	    	float planned_travel_duration;
	    	
	    	loop v over: vehicles {
	    		switch species(v) {
	    			match Car {
	    				current_vehicle <- v;
	    				return;
	    			}
	    			match Bike {
	    				ask v {
	    					planned_path <- compute_path_between(v.location, myself.current_destination);
	    				}
	    				if planned_path != nil {
	    					float t;
	    					loop r over: planned_path.edges {
	    						ask Road(r) {
	    							t <- get_theoretical_travel_time(v);
	    						}
	    						planned_travel_duration <- planned_travel_duration + t;
	    					}
	    					if planned_travel_duration < 30*60 {
	    						current_vehicle <- v;
	    						return;
	    					}  
	    				}
	    			}
	    			match Feet {
	    				ask v {
	    					planned_path <- compute_path_between(v.location, myself.current_destination);
	    				}
	    				if planned_path != nil {
	    					float t;
	    					loop r over: planned_path.edges {
	    						ask Road(r) {
	    							t <- get_theoretical_travel_time(v);
	    						}
	    						planned_travel_duration <- planned_travel_duration + t;
	    					}
	    					if planned_travel_duration < 30*60 {
	    						current_vehicle <- v;
	    						return;
	    					}  
	    				}
	    			}
	    		}
	    	}
	    	//if we are here it means no vehicles is find, so lets take the first one; our prefered one.
	    	current_vehicle <- vehicles[0];
	    	write get_current_date() + ": " + name + " is not super satisfied with its vehicle for the path it has to do but it will use: " + current_vehicle.name + " anyway.";
		}else{
			current_vehicle <- vehicles[0];
		}
    }
    
    action choose_vehicles {
    	//this method is called at initialisation in order to select the persons' vehicles in a preference order
    	int choice <- rnd_choice([feet_weight, bike_weight, car_weight, public_transport_weight]);
    	switch int(choice) {
    		match 0 {
	    	  	ask my_feet {
	    	  		do init_vehicle(myself);
	    	  	}
//	    	  	if flip(0.5) {
//	    	  		create Car returns: c;
//		    	  	ask c {
//		    	  		do init_vehicle(myself);
//		    	  	}
//	    	  	}else{
//	    	  		create Bike returns: b;
//		    	  	ask b {
//		    	  		do init_vehicle(myself);
//		    	  	}
//	    	  	}	    	  	
    		}
    		match 1 {
    			create Bike {
	    	  		do init_vehicle(myself);
	    	  	}
//	    	  	if flip(0.5) {
//	    	  		create Car returns: c;
//		    	  	ask c {
//		    	  		do init_vehicle(myself);
//		    	  	}
////		    	  	create Feet returns: f;
////		    	  	ask f {
////		    	  		do init_vehicle(myself);
////		    	  	}
//	    	  	}else{
////	    	  		create Feet returns: f;
////		    	  	ask f {
////		    	  		do init_vehicle(myself);
////		    	  	}
//	    	  	}
    		}
    		match 2 {
    			create Car {
	    	  		do init_vehicle(myself);
	    	  	}
//	    	  	if flip(0.5) {
////	    	  		create Feet returns: f;
////		    	  	ask f {
////		    	  		do init_vehicle(myself);
////		    	  	}
//	    	  	}else{
//	    	  		create Bike returns: b;
//		    	  	ask b {
//		    	  		do init_vehicle(myself);
//		    	  	}
////		    	  	create Feet returns: f;
////		    	  	ask f {
////		    	  		do init_vehicle(myself);
////		    	  	}
//	    	  	}
    		}
    		match 3 {
    			create PublicTransportCard {
	    	  		do init_vehicle(myself);
	    	  	}
//	    	  	if flip(0.5) {
////	    	  		create Feet returns: f;
////		    	  	ask f {
////		    	  		do init_vehicle(myself);
////		    	  	}
//	    	  	}else{
//	    	  		create Bike returns: b;
//		    	  	ask b {
//		    	  		do init_vehicle(myself);
//		    	  	}
////		    	  	create Feet returns: f;
////		    	  	ask f {
////		    	  		do init_vehicle(myself);
////		    	  	}
//	    	  	}
    		}
    		default {
    			write name + " has a ill-defined vehicle !" color: #red;
    		}
    	}
    }
    

   
   action highlight_path(int i){
//   		//probably deprecated
//       A REFAIRE
//   	 	bool found <- false;
//   		loop t over: journal.event_log {
//   			if t.trip_idx = i {
//	   			found <- true;
//	   			ask Road(t.road_gama_id) {
//	   				color <- #red;
//	   			}
//   			}
//	   	}
//	   	if !found {
//	   		write "Cannot find a matching path to highlight." color:#red;
//	   	}
   }
   
   action link_event_manager (EventManager e){
   		event_manager <- e;
//   		loop v over: vehicles {
//   			v.event_manager <- e;
//   		}
   		ask vehicles {
   			event_manager <- e;
   		}
   }
 
   
   
   //To add later
//   action cancel_highlight(int i){
//   		loop r over: past_paths[i] {
//			ask r {
//				color <- rgb(255 * (current_capacity / max_capacity), 0, 0);
//			}
//		}
//   }
    
    aspect default {
    	draw circle(10) color: color border: #black;
    }
	
	
	
	
	
	
}