/**
* Name: TransportGraph
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportGraph

import "TransportTrip.gaml"

species TransportGraph skills: [scheduling] schedules: [] {
	graph public_transport_graph;
	map<TransportEdge, float> weights;
	date last_update <- starting_date;
	
	init {
		write "Init of the public transport graph...";
		
		assert !empty(TransportStop);
		
		//add a connection between stops that are actually the same
	 	list<string> done_stops <- [];
	 	loop st1 over: TransportStop {
	 		if !(done_stops contains st1.real_name) {
		 		loop st2 over: TransportStop {
		 			if (st1 != st2) and (st1.location != st2.location) and (st2.real_name = st1.real_name) and (distance_to(st1.location, st2.location)) < 500 {
		 				create TransportEdge {
		 					source <- st1;
		 					target <- st2;
		 					shape <- polyline([source.location, target.location]);
		 					connection <- true; //important!
		 					weight <- Constants[0].connection_weight;
		 				}
		 				create TransportEdge {
		 					source <- st2;
		 					target <- st1;
		 					shape <- polyline([source.location, target.location]);
		 					connection <- true; //important!
		 					weight <- Constants[0].connection_weight;
		 				}
		 			}
		 		}	
		 		add st1.real_name to: done_stops;
		 	}
		}
		//
		
		loop st1 over: TransportStop {
		 	loop st2 over: TransportStop {
	 			if  (distance_to(st1.location, st2.location)) < Constants[0].allowed_walking_distance and (st1 != st2) and (st1.location != st2.location) {
	 				create TransportEdge {
	 					source <- st1;
	 					target <- st2;
	 					shape <- polyline([source.location, target.location]);
	 					connection <- true;
	 					walk_trip <- true; //important!
	 					weight <- distance_to(st1.location, st2.location)/3;
	 				}
	 			}
		 	}
		}
		//
		
		write "Done.";
	}
	
	list<pair<TransportStop, TransportTrip>> get_itinerary_between(point _s, point _t) {
		//refresh graph
		path p;
		list<pair<TransportStop, TransportTrip>> itinerary;
		date d <- get_current_date();
		
		//update graph
		if d > last_update {
			list<TransportEdge> available_edges <- TransportEdge where(each.connection = false and each.source_arrival_date > d);
			list<TransportEdge> connections <- TransportEdge where(each.connection);
			
			weights <- (connections + available_edges) as_map(each::(each.weight));
			public_transport_graph <- as_edge_graph(weights.keys) with_weights weights;
			public_transport_graph <- directed(public_transport_graph);
			
			last_update <- d;	
		}
		
		p <- path_between(public_transport_graph, _s, _t);
		
		if p != nil and !empty(p.edges) {
			//transform to an easier-to-read list 
			string current_edge_route_id;
			loop _elem over: p.edges {
				if TransportEdge(_elem).connection {
					if TransportEdge(_elem).walk_trip {
						add  TransportEdge(_elem).source::nil to: itinerary;
					}
				}else if TransportEdge(_elem).trip.route_id != current_edge_route_id {
					add  TransportEdge(_elem).source::TransportEdge(_elem).trip to: itinerary;
					current_edge_route_id <- TransportEdge(_elem).trip.route_id;
				}
			}
			add TransportEdge(last(p.edges)).target::nil to: itinerary;
			
			//clean to reduce unecessary connections
			/*
			if length(itinerary) > 1 {
				list<int> idx_to_delete;
				loop i from:0 to: length(itinerary)-2 {
					loop j from:i+1 to: length(itinerary)-1 {
						if itinerary[i].value != nil and itinerary[j].value != nil and  itinerary[i].value.route_id = itinerary[j].value.route_id {
							loop k from: i+1 to:j {
								if !(idx_to_delete contains k){
									add k to: idx_to_delete;
								}
							}
						}
					}	
				}
				//
				if !empty(idx_to_delete){
					loop i from: 0 to: length(idx_to_delete) - 1 {
						remove index: (idx_to_delete[i] - i) from: itinerary;	
					}
				}	
			}
			*/
			//to test
//			if last(itinerary).key.real_name = "Andromède-Lycée" {
//				loop e over: p.edges {
//					TransportEdge t <- TransportEdge(e);
//					if t.trip != nil {
//						write t.source.real_name + "-" + t.target.real_name + " via " + t.trip.trip_id + " " +t.connection;	
//					}else{
//						write t.source.real_name + "-" + t.target.real_name +  " " +t.connection color:#pink;	
//					}
//				}
//			}
			if all_match(itinerary, each.value = nil) {
				//this happens if the itinerary is only made of connections, in this case, the person should just walk
				//it seems to happen when it's very late and the transporttrip are all dead
				return nil;
			}
			if length(itinerary) = 2 and itinerary[0].key.real_name = itinerary[1].key.real_name {
				//weird case that happens with the graph
				return nil;
			}
			return itinerary;	
		}else{
			return nil;
		}
	}
	
	
}

