/**
* Name: Constants
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Constants

species Constants schedules: [] {
	//logs
	bool log_journals <- false const:true;
	bool log_roads <- false const:true;
	bool log_traffic <- false const:true;
	
	//vehicles
	float car_size <- 4.0 const:true;
	float bus_size <- 11.0 const:true;
	
	//person
	int starting_time_randomiser <- 120 const: true; //minutes
	float lateness_tolerance <- 300.0 const: true; //seconds
	//float ratio_exterior_workers <- 0.85 const: true; //[0;1]
	
	//road
	float minimum_road_capacity_required <- car_size const:true; //size of a car or a bus
	float speed_factor <- 0.7 const:true;
	float inflow_delay <- 2.0 const: true;
	float outflow_delay <- 3.0 const: true;
	float alpha <- 0.15 const:true;
	float beta <- 4.0 const:true;
	int deadlock_patience <- 2 const:true; //minutes
	
	//TransportStop
	float connection_weight <- 60.0 const:true; //in seconds
}

