/**
* Name: Person
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
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
	//bool is_going_in_ext_zone <- false; //used for display
	
	//
	Journal journal;
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
		//
		create Journal returns: j {
			owner <- myself;
		}
		journal <- j[0];
	}

	
	Building select_building (list<Building> l){
		return one_of(l);
	}
    
//	action select_agenda{
//        //write "select_agenda";
//        int i <- 0;
//        map<int,Agenda> available_agendas <- [];
//        loop p over:self.profile{
//            loop a over:Agenda{
//                if a.profile one_matches(each = p){
//                    add a to: available_agendas;
//                    i <- i+1;
//                }
//            }
//        }
//        personal_agenda <- one_of(available_agendas);
//    }
    

    action register_activities {
    	if !empty(activities) and !empty(starting_dates){
	    	assert length(activities) = length(starting_dates);
	    	date d;
	    	loop i from:0 to: length(activities)-1 {
	    		d <- starting_dates[i] add_minutes rnd(-floor(Constants[0].starting_time_randomiser/2), floor(Constants[0].starting_time_randomiser/2));
    	  		do later the_action: "start_activity" at: d ;
	    	}	
	    }
	    /* 
    	if !empty(activities) {
    		//current_activity <- activities[0];
    		date d <- starting_dates[0] add_minutes rnd(-floor(Constants[0].starting_time_randomiser/2), floor(Constants[0].starting_time_randomiser/2));
    	  	do later the_action: "start_activity" at: d ;
    	}else{
    		day_done <- true;
    		write get_current_date() + ": " + name + " will do nothing today.";
    	}
    	*/
    }
    
    action start_activity {    	
    	assert !empty(vehicles) warning: true;
    	act_idx <- act_idx + 1;
    	write get_current_date() + ": " + name + " starts activity" + act_idx color:#green;

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
//				dest <- any_location_in(living_building); TODO
				write "This building type is not defined !in Person" color: #red;
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
			//Vehicle old_one <- current_vehicle;
			do choose_current_vehicle;
			//if old_one != nil and old_one != current_vehicle {
			//	write "!!! -> " + name + " changed its mode !!! \n Now using " + current_vehicle.name + " instead of " + old_one.name color:#purple;
			//}
			if species(current_vehicle) = Car {
				do walk_to(current_vehicle.location);
			}else{
				do start_motion;	
			}
		}else{
			color <- #blue;
			write name + " is already at its destination. It will do its activity directly.";
			//date _end <- get_current_date() add_minutes current_activity.duration;
			//do later the_action: "end_activity" at: _end;
		}
		if act_idx = length(activities) -1 {
			//daydone
			day_done <- true;
		}
    }
    
//    action end_activity {
//    	color <- #black;
//    	
//    	if act_idx < length(activities) - 1 {
//    		act_idx <- act_idx + 1;
//    		current_activity <- personal_agenda.activities[act_idx];
//    		
//    		//check if we are not late on our agenda
//    		if current_activity.starting_date > get_current_date() {
//    			do later the_action: "start_activity" at: current_activity.starting_date;
//    		}else{
////    			write get_current_date() + ": " + name + " starts " + current_activity.title + " late on its agenda." color:#orange; 
//				//this may either be due to a past traffic jam situation or a the randomisation if the starting dates
//    			do later the_action: "start_activity" at: get_current_date() add_seconds 1;
//    		}
//    	}else{
//    		day_done <- true;
//    	}
//    }
    
    
    action start_motion{
//    	write get_current_date() + ": " + name + " takes vehicle: " + current_vehicle.name + " to do: " + current_activity.title;
    	is_moving_chart <- true;
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
//    	write get_current_date() + ": " + name + " starts doing: " + current_activity.title;
    	
    	//TODO
    	float lateness <- 0.0;
    	loop t over: journal.event_log {
    		if t.trip_idx = act_idx {
    			lateness <- lateness + t.lateness;
    		}
    	}
    	/*if act_idx < length(personal_agenda.activities) - 1 {
    		if lateness > Constants[0].lateness_tolerance {
    			write get_current_date()+ ": "+ name + " took " + lateness + " seconds more than planned to do its trip." color: #purple;    			
    			
    			if current_activity.priority_level <= personal_agenda.activities[act_idx+1].priority_level {
    				//we prefer to do the current activity (priority lvl in reverse order)
    				//here act_duration is the duration minus the theoretical travel time
    				
    				do later the_action: "end_activity" at: get_current_date() add_minutes (current_activity.duration + rnd(0,Constants[0].starting_time_randomiser));
    				write get_current_date() + ": " + name + " will do " + current_activity.title + " completely." color: #purple;
    			}else{
    				write get_current_date() +": " + name + " will reduce the time spent on " + current_activity.title + "." color: #purple;
    				date d <- personal_agenda.activities[act_idx+1].starting_date add_minutes rnd(0, Constants[0].starting_time_randomiser);
	    			if d <= get_current_date() {
	    				d <- get_current_date() add_seconds 1;
	    			}
	    			do later the_action: "end_activity" at: d;
    			}
    		}else{
    			date d <- personal_agenda.activities[act_idx+1].starting_date add_minutes rnd(0, Constants[0].starting_time_randomiser);
    			if d <= get_current_date() {
    				d <- get_current_date() add_seconds 1;
    			}
    			do later the_action: "end_activity" at: d;
    		}
    	}else{
    		//case: it was our last activity
    		do later the_action: "end_activity" at: get_current_date() add_minutes current_activity.duration;
    	} */   	
    }
    
    action walk_to(point p) {
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
   		//probably deprecated
   	 	bool found <- false;
   		loop t over: journal.event_log {
   			if t.trip_idx = i {
	   			found <- true;
	   			ask Road(t.road) {
	   				color <- #red;
	   			}
   			}
	   	}
	   	if !found {
	   		write "Cannot find a matching path to highlight." color:#red;
	   	}
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

//	list<date> init_read_dates(string s) {
//		list<date> r_list;
//    	list<string> l1 <- split_with(replace(s, "'", ""), ";");
//    	list<string> l2;
//    	
//    	loop e over: l1 {
//    		l2 <- split_with(e, ":");
//			
//    		add date(starting_date.year, starting_date.month, starting_date.day, int(l2[0]), int(l2[1]), 0) to: r_list;
//    	}
//    	return r_list;
//    }
//    
//    list<int> init_read_activities(string s) {
//		list<int> r_list;
//		int act;
//		write s;
//		loop e over: split_with(s, ",") {
//			act <- int(e);
//			if act < 10 {
//				act <- 0;
//			}else if act < 20 {
//				act <- 1;
//			}else if act < 30 {
//				act <- 2;
//			}else if act < 40 {
//				act <- 3;
//			}else if act < 50 {
//				act <- 4;
//			}else if act < 60 {
//				act <- 5;
//			}else if act < 70 {
//				act <- 6;
//			}else if act < 80 {
//				act <- 7;
//			}else if act < 90 {
//				act <- 8;
//			}else if act < 100 {
//				act <- 9;
//			}
//			add act to: r_list;
//		}
//    	 return r_list;
//    }
   
   
   
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