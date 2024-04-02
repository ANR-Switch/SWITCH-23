/**
* Name: ResidualFlow
* Based on the internal empty template. 
* Author: flavi
* Tags: 
*/


model ResidualFlow

//import "Building.gaml"

import "../Vehicles/VehicleFactory.gaml"

import "../Person.gaml"

//import "Road.gaml"

/* Insert your model definition here */
//weight 100% car : [0,0,1,0]
species ResidualFlow skills: [scheduling] schedules: [] {
	int id;
	bool is_in;
	string coresponding_highway;
	string string_od;
	
	list<int> matrice_OD_daily;
	list<list<int>> matrice_OD;
	map<ResidualFlow,list<int>> map_OD;
	list<ResidualFlow> destination_list;
	
	list<float> frequency_tab_daily;
	list<list<float>> frequency_tab;
	
	list<float> matrice_duration <- [6#h,3#h,7#h,3#h,5#h];
	int current_matrice <- 0;
	float time_since_previous_matrice <- 0.0;
	int count_residual_vehicle;
	
	VehicleFactory factory;
	//EventManager event_manager;
	Logger log;
	Logger csvlog;
	
	//map<int,ResidualFlow> destination_map;
	
	init{
		create VehicleFactory;
		factory <- VehicleFactory[0];
		
	}
	action init_OD{
		list<float> tmp_list;
		
		int i <- 0;
		loop vector over:matrice_OD{
			loop value over:vector{
				add (value/(matrice_duration[i]/step)) to:tmp_list;
			}
			add tmp_list to:frequency_tab;
			tmp_list <-[];
			i <- i+1;
		}
		loop value over:matrice_OD_daily{
			add (value/(24#h/step)) to:frequency_tab_daily;
		}
		
	}
	  /*action register_activities {
    	if !empty(activities) and !empty(starting_dates){
	    	assert length(activities) = length(starting_dates);
	    	date d;
	    	//loop i from:0 to: length(activities)-1 {
    		d <- starting_dates[0] add_minutes floor(rnd(-(Constants[0].starting_time_randomiser/2), (Constants[0].starting_time_randomiser/2)));
	  		msg_sent <- msg_sent+1;
	  		do later the_action: "start_activity" at: d ;
	    	//}	
	    }
    }*/
    
    action init_flow{
    	
    	date sent_date;
    	loop matrice over:frequency_tab{
    		loop flow over:matrice{
    			if flow<1{
					if(flip(flow)){
						do later the_action:'send_vehicule' with_arguments:map("destination"::1) at:sent_date;
					}
					else{
						loop times:flow-1{
							do later the_action:'send_vehicule' with_arguments:map("destination"::1) at:sent_date;
						}
					}
				}
    		}
    	}
    }
	
	//do later the_action: "deadlock_prevention" with_arguments: map("vehicle"::vehicle) at: t;
	action create_flow {//when:is_in{
	
		if is_in{
			
			int i <- 0;
			date sent_date <- current_date;
			
			
			loop flow over:frequency_tab[current_matrice]{
				if flow > 0{
					if flow<1{
						if(flip(flow)){
							do later the_action:'send_vehicule' with_arguments:map("destination"::destination_list[i]) at:sent_date+rnd(0,step);
						}
					}
					else{
						loop times:flow{
							do later the_action:'send_vehicule' with_arguments:map("destination"::destination_list[i]) at:sent_date+rnd(0,step);
						}
					}
				}
				
				i <- i+1;
			}
			time_since_previous_matrice <- time_since_previous_matrice+step;
		
			if time_since_previous_matrice> matrice_duration[current_matrice]{
				current_matrice <- current_matrice+1;
				time_since_previous_matrice<-0.0;
			}
		}
	
	}
	
	action send_vehicule(ResidualFlow destination){
		//write ''+self.id+" create flow to : "+destination.id;
		//write "send_vehicule date : " + get_current_date();
		ResidualVehicle	new_vehicle <- ResidualVehicle(factory.create_residual_vehicles(location));
		ask new_vehicle{
			start_autoroute <- myself;
			dest_autoroute <- destination;
			//location <- myself.location; 
			
			self.id <- myself.id*100000+myself.count_residual_vehicle;
			log <- myself.log;
			event_manager <- myself.event_manager;
			do go_to(start_autoroute.location,dest_autoroute.location);
		}
		count_residual_vehicle <- count_residual_vehicle+1;
	}
}