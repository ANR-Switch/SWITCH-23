/**
* Name: Stop
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model TransportStop

/* Insert your model definition here */

species TransportStop schedules: [] {
	string id;
	int code;
	string real_name;
	
	
	aspect default {
		draw circle(20) color: #purple;
	}
}