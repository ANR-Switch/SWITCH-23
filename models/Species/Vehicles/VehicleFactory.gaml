/**
* Name: VehicleFactory
* Based on the internal empty template. 
* Author: flavi
* Tags: 
*/


model VehicleFactory

import "residualVehicle.gaml"

import "Vehicle.gaml"

import "Bike.gaml"

import "Feet.gaml"

import "Car.gaml"

species VehicleFactory{
	Vehicle create_vehicles(list<float> weights, Person p, Logger l) {
		int choice <- rnd_choice(weights);
		Vehicle v;
    	switch int(choice) {
    		match 0 {
	    	  	create Feet {
	    	  		do init_vehicle(p,l);
	    	  	}
	    	  	v<- Feet[0];
    		}
    		match 1 {
    			create Bike {
	    	  		do init_vehicle(p,l);
	    	  	}
	    	  	v<- Bike[0];
    		}
    		match 2 {
    			create Car {
	    	  		do init_vehicle(p,l);
	    	  	}
	    	  	v<- Car[0];

    		}
    		match 3 {
    			create PublicTransportCard {
	    	  		do init_vehicle(p);
	    	  	}
	    	  	v<- PublicTransportCard[0];
    		}
    		default {
    			write name + " has a ill-defined vehicle !" color: #red;
    			
    		}
    		return v;
    	}
    	
    }
    
    Vehicle create_residual_vehicles(point l){
    	create ResidualVehicle with:[location::l];
    	return ResidualVehicle[length(ResidualVehicle)-1];
    }

	
}
