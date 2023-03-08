/**
* Name: Building
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Building

species Building {
	string type;
	rgb color;

	aspect default {
		draw shape color: color border: #black;			
	}

}
