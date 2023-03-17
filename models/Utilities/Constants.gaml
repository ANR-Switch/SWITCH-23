/**
* Name: Constants
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Constants

species Constants {
	//person
	float cyclists_ratio <- 1.0 const: true;
	int starting_time_randomiser <- 15 const: true; //minutes
	float lateness_tolerance <- 300.0 const: true; //seconds
	
	//road
	int deadlock_patience <- 5 const:true; //minutes
}

