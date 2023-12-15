/**
* Name: CreateRoadNul
* Based on the internal empty template. 
* Author: flavi
* Tags: 
*/


model CreateRoadNul

import "../models/Utilities/Constants.gaml"

import "../models/Species/Map/Road.gaml"

/*	lanes::int(read("NB_VOIES")), 
	max_speed::float(read("VIT_MOY_VL")),
	oneway::string(read("SENS")),
	topo_id::string(read("ID")),
	allowed_vehicles::string(read("VEHICULES")),
	importance::int(read("IMPORTANCE")),
	event_manager::EventManager[0] */






global{
	Road route;
	Person bob;
	Car voiture;
	
	init {
		create Constants;
		create EventManager number:1;
		current_date <- starting_date;
		
		create Road number:1 returns: routes with:[
			lanes::1,
			max_speed::50.0 #km/#h,
			oneway::'no',
			topo_id::'1',
			allowed_vehicles::'0',
			importance::1,
			event_manager::EventManager[0]
		]{}
		 	route<- routes[0];
		
		
		create Person number:1 with:[]{}
		bob <- Person[0];
		create Car with:[speed::50#km/#h,owner::bob,length::1]{my_path<- path(routes);}
		voiture <- Car[0];
		
		ask bob {do link_event_manager(EventManager[0]);}
		
		ask voiture {
			do propose();
		}
		write route.current_capacity;
		//assert route.current_capacity = 1;
	}
	
}


/* Insert your model definition here */
experiment "pouet"{
	
}


