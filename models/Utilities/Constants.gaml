/**
* Name: Constants
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
* Commented
*/


model Constants

species Constants {
	/*
	 * this factor is to reduce the capacity of the roads to avoid having to simulate the whole population.
	 * One can model 1/10th of the population by reducing the roads' capacity of a factor 10 too.
	 */
	int simulation_reduction_factor <- 1 const:true;
	
	//false to avoid charging all the public-transport-related agents
	bool load_public_transports <- false const: true;
	
	////Logs.gaml
	bool log_journals <- false const:true;
	bool log_roads <- false const:true;
	bool log_traffic <- false const:true;
	
	////Vehicles.gaml
	float car_size <- 4.0#m * simulation_reduction_factor const:true;
	float bus_size <- 11.0#m const:true;
	
	////PublicTransportCard.gaml
	/*
	 * Le temps a attendre sur place avant de recalculer un trajet de transport en commun
	 */
	int waiting_time_before_recomputing <- 20 const: true;
	
	////Person.gaml
	int starting_time_randomiser <- 5 const: true; //minutes
	//float lateness_tolerance <- 300.0 const: true; //seconds
	//float ratio_exterior_workers <- 0.85 const: true; //[0;1] //les gens qui sortent de la zone smulée pour aller travailler à l'exterieure
	
	////Road.gaml
	bool double_the_roads <- false const:true; //true if the database does not pre-double the roads for both direction, in this case we do it at initial time
	float minimum_road_capacity_required <- car_size const:true; //size of a car or a bus
	
	float speed_factor <- 1.0 const:true;
	float inflow_delay <- 2.0 const: true;
	float outflow_delay <- 3.0 const: true;
	
	/*
	 * Constantes classiques des modèles routiers. Laisser sur ces valeurs.
	 */
	float alpha <- 0.15 const:true; //0.15
	float beta <- 4.0 const:true;   //4.0
	
	/* temps avant qu'une voiture s'insere de force sur la route, pour défaire les deadlocks */
	int deadlock_patience <- 30 const:true; //seconde
	
	////TransportGraph.gaml
	/*
	 * Si true, le graphe des transports en communs s'update en fonction de l'heure, mais c'est lourd et pas au point pour l'instant
	 */
	bool dynamic_public_transport_graph <- false const:true;
	
	/*
	 * Autorise des jonctions à pieds entre des arrets proches dans un certain rayon
	 */
	bool walking_connections <- true const: true;
	int allowed_walking_distance <- 500 const:true; //meters to allow a "walk" connection between two stops in the public transport network
	
	////TransportStop.gaml
	float connection_weight <- 0.0 const:true; //in seconds has to be 0 for now
	
	////TransportTrip.gaml
	/*
	 * a trip will add itself to the transportgraph this many minutes before starting the bus/metro/...
	 * utile seulement si le graphe est dynamique
	 */
	int minutes_for_graph_registration <- 15 const: true; 
	
	////TransportRoute.gaml
	/*
	 * On ajoute ce poids à chaque segment du graphe, ça représente le temps de sortir de Trasport en Commun.
	 * Grace à ca on peut favoriser les trajets avec le moins de changements 
	 */
	int connection_penalty <- 100 const:true; //minutes, it is to make the graph minimize the change between edges

}


