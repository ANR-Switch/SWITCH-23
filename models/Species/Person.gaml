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
	Building living_building;
	int act_idx <- 0; 
	Activity current_activity;
	
	//
//	Constants constants;
	int randomiser <- 10;
	float lateness <- 0.0;
	float total_lateness <- 0.0;
	float lateness_tolerance <- 180.0 const: true; //seconds
	float theoretical_travel_duration;
	rgb color <- #grey;
	Vehicle vehicle;
	
	init {
		do choose_vehicle();
	}
	
	action select_living_building(list<Building> living_buildings){
		living_building <- one_of(living_buildings);
		location <- any_location_in(living_building);
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
//    	  	create Car returns: c;
//    	  	ask c {
//    	  		do init_vehicle(myself);
//    	  	}
    	}else{
    		write get_current_date() + ": " + name + " will do nothing today.";
    	}
    }
    
    
    
    action start_activity {    	
    	assert vehicle != nil warning: true;
    	assert current_activity.activity_location != nil warning: true;
    	
		if location != current_activity.activity_location {
			do start_motion(current_activity.activity_location);
		}else{
			color <- #blue;
			write name + " is already at its destination. It will do its activity directly.";
			date _end <- get_current_date() add_minutes current_activity.duration;
			do later the_action: "end_activity" at: _end;
		}
    }
    
    action end_activity {
    	write get_current_date() + ": " + name + " ends " + current_activity.title;
    	color <- #grey;
    	
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
//    		ask vehicle {
//    			do die;
//    		}
    	}
    }
    
    action start_motion(point p){
    	write get_current_date() + ": " + name + " takes vehicle: " + vehicle.name + " to do: " + current_activity.title;
    	color <- #yellow;
    	ask vehicle{
    		do add_passenger(myself);
			do goto(p);
		}
    }
    
    action end_motion {
    	ask vehicle{
    		do remove_passenger(myself);
    	}
    	write get_current_date() + ": " + name + " starts doing: " + current_activity.title;
    	color <- #blue;
    	total_lateness <- total_lateness + lateness;
    	
    	if act_idx < length(personal_agenda.activities) - 1 {
    		if lateness > lateness_tolerance {
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
    
    action choose_vehicle {
    	if flip(Constants[0].cyclists_ratio){
    		create Bike returns: b;
    	  	ask b {
    	  		do init_vehicle(myself);
    	  	}
    	}else{
    		create Car returns: c;
    	  	ask c {
    	  		do init_vehicle(myself);
    	  	}
    	}
    }
    
    aspect default {
    	draw circle(5) color: color border: #black;
    }
	
	
	
	
	
	
}