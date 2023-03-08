/**
* Name: Map
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Map

import "Road.gaml"

import "Building.gaml"

species Map_unused {
	/*
	 * this class is a global map that stores every useful information for all agents
	 */
	//loading parameters defined in World
//	string dataset_path ;
	shape_file shape_roads ;
//	shape_file shape_nodes <- shape_file(dataset_path + "nodes.shp");
	shape_file shape_boundary ;
	shape_file shape_buildings ;
//	geometry shape <- envelope(shape_boundary);
	
	 
	 
	 //
	 //class paramters
	 date sim_starting_date; //global variable that may be useful for agents
	 
	 graph road_graph;
	 //graph others;
	 
	 list<Building> working_buildings;
	 list<Building> living_buildings;
	 
	 init{
	 	do init_buildings;
	 	do init_roads;
	 	do init_graphs;
	 	write "The Map agent is ready.";
	 }
	 
	 action init_buildings {
	 	write "Building...";
		create Building from: shape_buildings with: [type::string(read("NATURE"))]{
			if type="Industrial" {
				color <- #blue;
				
				add self to: myself.working_buildings;
			}else{
				color <- #gray;
				
				add self to: myself.living_buildings;
			}
		}
		write length(working_buildings);
		write "Buildings loaded.";
	 }
	 
	 action init_roads {
	 	write "Road...";
		create Road from: shape_roads;
		write "Roads loaded.";
	 }
	 
	 action init_graphs {
	 	write "Graphs...";
	 	road_graph <- as_edge_graph(Road);
	 	write "Graphs are ready.";
	 }
}

