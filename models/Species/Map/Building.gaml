/**
* Name: Building
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Building

species Building schedules: [] {
	int type;
	rgb color;
	string real_name;

	aspect default {
		draw shape color: color border: #black;			
	}

}
