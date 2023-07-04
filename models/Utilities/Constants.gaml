/**
* Name: Constants
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Constants

species Constants schedules: [] {
	/*
	 * this factor is to reduce the capacity of the roads to avoid having to simulate the whole population.
	 * One can model 1/10th of the population by reducing the roads' capacity of a factor 10 too.
	 */
	int simulation_reduction_factor <- 1 const:true;
	
	//false to avoid charging all the public-transport-related agents
	bool public_transports <- true const: true;
	
	//logs
	bool log_journals <- true const:true;
	bool log_roads <- false const:true;
	bool log_traffic <- false const:true;
	
	//vehicles
	float car_size <- 4.0 * simulation_reduction_factor const:true;
	float bus_size <- 11.0 const:true;
	
	//PublicTransportCard
	int waiting_time_before_recomputing <- 20 const: true;
	
	//person
	int starting_time_randomiser <- 120 const: true; //minutes
	float lateness_tolerance <- 300.0 const: true; //seconds
	//float ratio_exterior_workers <- 0.85 const: true; //[0;1]
	
	//road
	bool double_the_roads <- true const:true; //true if the database does not pre-double the roads for both direction, in this case we do it at initial time
	float minimum_road_capacity_required <- car_size const:true; //size of a car or a bus
	
	float speed_factor <- 1.0 const:true;
	float inflow_delay <- 2.0 const: true;
	float outflow_delay <- 3.0 const: true;
	float alpha <- 0.15 const:true;
	float beta <- 4.0 const:true;
	int deadlock_patience <- 2 const:true; //minutes
	
	//TransportGraph
	bool dynamic_public_transport_graph <- false const:true;
	int allowed_walking_distance <- 100 const:true; //meters to allow a "walk" connection between two stops in the public transport network
	
	//TransportStop
	float connection_weight <- 0.0 const:true; //in seconds has to be 0 for now
	
	//TransportTrip
	int minutes_for_graph_registration <- 15 const: true; //a trip will add itself to the transportgraph this many minutes before starting the bus/metro/...

	//TransportRoute
	int connection_penalty <- 10 const:true; //minutes, it is to make the graph minimize the change between edges

}

