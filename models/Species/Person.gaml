/**
* Name: Person
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Person

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
	Agenda personal_agenda;
	Building current_building;
	Building next_building;
	Building living_building;
	Building working_building;
	Building commercial_building;
	Building studying_building;
	Building leasure_building;
	
	//
	int act_idx <- 0; 
	Activity current_activity;
	
	//
	point current_destination; 
	date start_motion_date;
	float total_travel_time <- 0.0;
	float lateness <- 0.0;
	float total_lateness <- 0.0;
	float lateness_tolerance <- Constants[0].lateness_tolerance const: true; //seconds
	float theoretical_travel_duration;
	float walking_speed <- 1.39 ; //#meter / #second ;
	rgb color <- #black;
	Vehicle current_vehicle;
	list<Vehicle> vehicles <- [];
	
	//output display
	bool is_moving_chart <- false; //used for display
	list<list<Road>> past_motions;
	
//	init {
//
//	}

	
	Building select_building (list<Building> l){
		return one_of(l);
	}
    
	action select_agenda{
        //write "select_agenda";
        int i <- 0;
        map<int,Agenda> available_agendas <- [];
        loop p over:self.profile{
            loop a over:Agenda{
                if a.profile one_matches(each = p){
                    add a to: available_agendas;
                    i <- i+1;
                }
            }
        }
        personal_agenda <- one_of(available_agendas);
    }
    
    action register_first_activity {
    	if !empty(personal_agenda.activities) {
    		current_activity <- personal_agenda.activities[0];
    		date d <- current_activity.starting_date add_minutes rnd(-floor(Constants[0].starting_time_randomiser/2), floor(Constants[0].starting_time_randomiser/2));
    	  	do later the_action: "start_activity" at: d ;
    	}else{
    		write get_current_date() + ": " + name + " will do nothing today.";
    	}
    }
    
    
    
    action start_activity {    	
    	assert !empty(vehicles) warning: true;
//    	assert current_activity.activity_location != nil warning: true;
		switch int(current_activity.type){
			match 0 {
				current_destination <- any_location_in(living_building);
				next_building <- living_building;
			}
			match 1 {
				current_destination <- any_location_in(working_building);
				next_building <- working_building;
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
			if species(current_vehicle) = Car {
				do walk_to(current_vehicle.location);
			}else{
				do start_motion;	
			}
		}else{
			color <- #blue;
			write name + " is already at its destination. It will do its activity directly.";
			date _end <- get_current_date() add_minutes current_activity.duration;
			do later the_action: "end_activity" at: _end;
		}
    }
    
    action end_activity {
    	write get_current_date() + ": " + name + " ends " + current_activity.title;
    	color <- #black;
    	
    	if act_idx < length(personal_agenda.activities) - 1 {
    		act_idx <- act_idx + 1;
    		current_activity <- personal_agenda.activities[act_idx];
    		
    		//check if we are not late on our agenda
    		if current_activity.starting_date > get_current_date() {
    			do later the_action: "start_activity" at: current_activity.starting_date;
    		}else{
//    			write get_current_date() + ": " + name + " starts " + current_activity.title + " late on its agenda." color:#orange; 
				//this may either be due to a past traffic jam situation or a the randomisation if the starting dates
    			do later the_action: "start_activity" at: get_current_date() add_seconds 1;
    		}
    	}else{
    		write get_current_date() + ": " + name + " ended its day."; 
    	}
    }
    
    
    action start_motion{
    	write get_current_date() + ": " + name + " takes vehicle: " + current_vehicle.name + " to do: " + current_activity.title;
    	start_motion_date <- get_current_date();
    	is_moving_chart <- true;
    	ask current_vehicle{
    		do add_passenger(myself);
			do goto(myself.current_destination);
		}
    }
    
    action end_motion {
//    	location <- current_destination;
    	current_building <- next_building;
    	color <- current_building.color;
    	is_moving_chart <- false;
    	
    	total_travel_time <- total_travel_time + (get_current_date() - start_motion_date);
    	
    	ask current_vehicle{
    		do remove_passenger(myself);
    	}
    	write get_current_date() + ": " + name + " starts doing: " + current_activity.title;
    	
    	if act_idx < length(personal_agenda.activities) - 1 {
    		if lateness > lateness_tolerance {
    			total_lateness <- total_lateness + lateness;
    			write get_current_date() + name + " took " + lateness + " seconds more than planned to do its trip." color: #purple;    			
    			
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
    	}    	
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
    
    action choose_vehicle {
    	int choice <- rnd_choice([feet_weight, bike_weight, car_weight]);
    	switch int(choice) {
    		match 0 {
    			create Feet returns: f;
	    	  	ask f {
	    	  		do init_vehicle(myself);
	    	  	}
    		}
    		match 1 {
    			create Bike returns: b;
	    	  	ask b {
	    	  		do init_vehicle(myself);
	    	  	}
    		}
    		match 2 {
    			create Car returns: c;
	    	  	ask c {
	    	  		do init_vehicle(myself);
	    	  	}
    		}
    		default {
    			write name + " has a ill-defined vehicle !" color: #red;
    		}
    	}
    }
   
   action highlight_motion(int i){
   		if length(past_motions) > i {
   			loop r over: past_motions[i] {
   				ask r {
   					do highlight;
   				}
   			}
   		}else{
   			write "Cannot highlight the motion as " + name + " only registered " + length(past_motions) + " motions.";
   		}
   }
    
    aspect default {
    	draw circle(10) color: color border: #black;
    }
	
	
	
	
	
	
}