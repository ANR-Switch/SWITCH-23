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
	
	init {
		write "Init of the public transport graph...";
		
		assert !empty(TransportStop);
		
		//add a connection between stops that are actually the same
	 	list<string> done_stops <- [];
	 	loop st1 over: TransportStop {
	 		if !(done_stops contains st1.real_name) {
		 		loop st2 over: TransportStop {
		 			if (st1 != st2) and (st2.real_name = st1.real_name) and (distance_to(st1.location, st2.location)) < 500 {
		 				create TransportEdge {
		 					source <- st1;
		 					target <- st2;
		 					shape <- polyline([source.location, target.location]);
		 					connection <- true; //important!
		 				}
		 				create TransportEdge {
		 					source <- st2;
		 					target <- st1;
		 					shape <- polyline([source.location, target.location]);
		 					connection <- true; //important!
		 				}
		 			}
		 		}	
		 		add st1.real_name to: done_stops;
		 	}
		}
		write "Done.";
	}
	
	list<pair<TransportStop, TransportTrip>> get_itinerary_between(point _s, point _t) {
		//refresh graph
		path p;
		list<pair<TransportStop, TransportTrip>> itinerary;
		date d <- get_current_date();
		list<TransportEdge> available_edges <- TransportEdge where(each.connection = false and each.arrival_date >= d);
		list<TransportEdge> connections <- TransportEdge where(each.connection);
		
		ask connections {
			arrival_date <- d;		
		}
		
		weights <- (connections + available_edges) as_map(each::(each.arrival_date-d));
		public_transport_graph <- as_edge_graph(TransportEdge) with_weights weights;
		public_transport_graph <- directed(public_transport_graph);
		
		p <- path_between(public_transport_graph, _s, _t);
		
		//transform to an easier-to-read list 
		string current_edge_route_id;
		loop _elem over: p.edges {
			if TransportEdge(_elem).connection {
				//add connection
				add TransportEdge(_elem).source::nil to: itinerary;
			}else if TransportEdge(_elem).trip.route_id != current_edge_route_id {
				add  TransportEdge(_elem).source::TransportEdge(_elem).trip to: itinerary;
				current_edge_route_id <- TransportEdge(_elem).trip.route_id;
			}
		}
		
		//clean to reduce unecessary connections
		list<int> idx_to_delete;
		loop i from:0 to: length(itinerary)-2 {
			loop j from:i+1 to: length(itinerary)-1 {
				if itinerary[i].value != nil and itinerary[j].value != nil and  itinerary[i].value.route_id = itinerary[j].value.route_id {
					loop k from: i+1 to:j {
						add k to: idx_to_delete;
					}
				}
			}
		}
		//
		loop i from: 0 to: length(idx_to_delete) - 1 {
			remove index: (idx_to_delete[i] - i) from: itinerary;
		}
		
		return itinerary;
	}
	
	
}

