/**
* Name: Person
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Person

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
	float lateness <- 0.0;
	rgb color <- #grey;
	Vehicle vehicle;
	
	init {
		
	}
	
	action select_living_building(list<Building> living_buildings){
		living_building <- one_of(living_buildings);
		location <- any_location_in(living_building);
	}
	
	action salt_agenda{
        loop acti over: personal_agenda.activities{
            acti.starting_date <- acti.starting_date add_minutes rnd(-15,15) ;
//            write acti.starting_date;
            acti.duration <- acti.duration + rnd(-5,5);
            if (acti.duration < 0) {
            	acti.duration <- 1;
            }
        }
    }
    
	action select_agenda{
        list<Agenda> available_agendas <- [];
        loop p over: self.profile{
            loop a over: Agenda{
                if a.profile one_matches(each = p){
                    add a to: available_agendas;             
                }
            }
        }
        Agenda template <- one_of(available_agendas);
//        assert length(a) = 1;
// may be a better way to duplicate agents
        create Agenda returns: my_agenda {
        	name <- template.name;
        	id <- template.id;
        	owner <- myself; //TODO may be removed ?
        	loop act over: template.activities {
        		create Activity returns: _a {
        			id <- act.id;
					title <- act.title;
					priority_level <- act.priority_level;
					type <- act.type;
					starting_minute <- act.starting_minute;
					starting_date <- act.starting_date;
					duration <- act.duration;
					activity_location <- act.activity_location;
        		}
        		add _a[0] to: activities;
        	}
        } 
        personal_agenda <- my_agenda[0];
    }
    
    action register_first_activity {
    	if !empty(personal_agenda.activities) {
    		current_activity <- personal_agenda.activities[0];
    	  	do later the_action: "start_activity" at: current_activity.starting_date;
    	  	create Car returns: c;
    	  	ask c {
    	  		do init_vehicle(myself);
    	  	}
    	}else{
    		write get_current_date() + ": " + name + " will do nothing today.";
    	}
    }
    
    action start_activity {
    	write get_current_date() + ": " +  name + " starts " + current_activity.title ;
    	
    	assert vehicle != nil warning: true;
    	assert current_activity.activity_location != nil warning: true;
    	
		if location != current_activity.activity_location {
			do start_motion(current_activity.activity_location);
		}else{
			color <- #green;
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
    			write get_current_date() + ": " + name + " starts " + current_activity.title + " late on its agenda." color:#orange; 
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
    	color <- #green;
    	if act_idx < length(personal_agenda.activities) - 1 {
    		date t_next <- personal_agenda.activities[act_idx + 1].starting_date ;
    		date t_end <- get_current_date() add_minutes current_activity.duration ; 
    		
    		if t_end <= t_next {
    			write get_current_date() + ": " + name + " starts doing: " + current_activity.title + " for " + current_activity.duration + " minutes.";
    			do later the_action: "end_activity" at: t_end;
    		}else{
    			float overlap <- t_end - t_next;
    			write get_current_date() + ": " + name + " is late." color: #orange;
    			if current_activity.priority_level <= personal_agenda.activities[act_idx + 1].priority_level {
    				//the most important level is 0, decreasing order.
    				//do the current one and the next ones will be late    				
    				write "The end of " + current_activity.title + " overlaps the next activity: " + personal_agenda.activities[act_idx + 1].title + " by " + overlap + " seconds" color:#orange;
    				write "But " + name+ " will complete its current activity and start the next one late." color:#orange; 
    				do later the_action: "end_activity" at: t_end;
    			}else{    				
    				if get_current_date() < personal_agenda.activities[act_idx + 1].starting_date add_seconds -1 {
    					float span_time <- personal_agenda.activities[act_idx + 1].starting_date - get_current_date() - 1;
    					write name + " will do: " + current_activity.title + " for " + span_time+ " seconds instead of the " + current_activity.duration + " seconds planned in order to start: " + personal_agenda.activities[act_idx + 1].title + " on time." color: #red;
    					do later the_action: "end_activity" at: personal_agenda.activities[act_idx + 1].starting_date add_seconds -1;	
    				}else{
    					write name + " will not do " + current_activity.title + " because it is too late and the next activity is more important." color: #red;
    					do later the_action: "end_activity" at: get_current_date() add_seconds 1;
    				}
    			}
    		}
    	}else{
    		//case: it was our last activity
    		write get_current_date() + ": " + name + " starts doing: " + current_activity.title + " for " + current_activity.duration + " minutes. It is its last activity.";
    		do later the_action: "end_activity" at: get_current_date() add_minutes current_activity.duration;
    	}
    	
    }
    
    aspect default {
    	draw circle(2) color: color border: #black;
    }
	
	
	
	
	
	
}