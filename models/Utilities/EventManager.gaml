/**
* Name: EventManager
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model EventManager

/** 
 * Event manager species
 */
species EventManager control: event_manager {

	
		
	reflex write_size {
		write "[" + name + "] manager size = " + size + " at " + current_date;
	}

}