/*
* Name: Road
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

model Road

import "../Vehicles/Vehicle.gaml"

species Road skills: [scheduling] schedules: [] {
	int id;
	int lanes <- 1; //From shapefile 
	float max_speed <- 50.0 #km / #h; // From shapefile
	string oneway <- "no"; //From shapefile
	list<list<int>> allowed_vehicles;
	point trans <- {2.0, 2.0};
	geometry displayed_shape;
	
	//traffic attributes
	float current_capacity <- 0.0;
	float max_capacity <- shape.perimeter * lanes;
	float alpha <- 0.15 const: true;
	float beta <- 4.0 const: true;
	date last_entry;
	date last_exit;
	float inflow_delay <- 1.0 const: true;
	float outflow_delay <- 1.0 const: true;
	float gap_travel_time <- shape.perimeter / 2; 
	int deadlock_delay <- 2 const: true; //minutes to try to force the car inside the road
	list<pair<Vehicle, date>> _queue; //queue is a build-in name so we use _queue
	list<Vehicle> waiting_list;
	
	//test
	float max_tmp_alocated_test;	

	init {
		point A <- first(shape.points);
		point B <- last(shape.points);
		if (A = B) {
			trans <- {0, 0};
		} else {
			point u <- {-(B.y - A.y) / (B.x - A.x), 1};
			float angle <- angle_between(A, B, A + u);
			if (angle < 150) {
				trans <- u / norm(u);
			} else {
				trans <- -u / norm(u);
			}

		}
		displayed_shape <- (shape + lanes) translated_by (trans * 2);

		//some security checks
		if max_capacity < 5.0 {
			max_capacity <- 5.0;
			write name + " defines the minimum max_capacity value." color:#orange;
		}
		
//		do auth_vehicles_init;
	
	}
	
	action accept(Vehicle vehicle){
		date leave_date;
		float speed <- min(vehicle.speed, max_speed);
		float t_min <- ceil(shape.perimeter / speed);//minimum time spent on the road
		if(t_min < 1.0){
			t_min <- 1.0;
		}
		
//		assert current_capacity + vehicle.length <= max_capacity warning: true;
		//////////////////////////////
//		if vehicle.has_width {
//			if empty(_queue){
//				//case: the vehicle can only go out if it's the first in queue
//				leave_date <- get_current_date() add_seconds t_min;
//				do add(vehicle, leave_date);
//				do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
//			}else{
//				//case: is there a non overtakable vehicle in front of us ?
//				bool _bool <- is_there_width_vehicle();
//
//				if _bool {
//					float capacity_ratio <- compute_capacity_ratio_for_traffic();
//					float t <- t_min * ( 1 + alpha * capacity_ratio ^ beta );
//					leave_date <- get_current_date() add_seconds t;
//					//case: we do not schedule a leaving time yet
////					write get_current_date() + ": entered but its not first in queue on " + name;
//					do add(vehicle, leave_date);
//				}else{
//					//case: there are some vehicle in front of us but we can overtake them (they are pedestrians or cyclists)
//					leave_date <- get_current_date() add_seconds t_min;
//					do add(vehicle, leave_date);
//					do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
//				}
//			}
//		}else{
//			//case: we can overtake or be overtaken so no traffic influence required
//			leave_date <- get_current_date() add_seconds t_min;
//			do add(vehicle, leave_date);
//			do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
//		}	
		////////////////////////
		switch species(vehicle){
			match Bike {
				leave_date <- get_current_date() add_seconds t_min;
				do add(vehicle, leave_date);
				do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
			}
			match Feet {
				leave_date <- get_current_date() add_seconds t_min;
				do add(vehicle, leave_date);
				do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
			}
			match Car {
				if empty(_queue){
					//case: the vehicle can only go out if it's the first in queue
					leave_date <- get_current_date() add_seconds t_min;
					do add(vehicle, leave_date);
					do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
				}else{
					//case: is there a non overtakable vehicle in front of us ?
					bool _bool <- is_there_blocking_vehicle();
	
					if _bool {
						float capacity_ratio <- compute_capacity_ratio_for_traffic();
						float t <- t_min * ( 1 + alpha * capacity_ratio ^ beta );
						leave_date <- get_current_date() add_seconds t;
						//case: we do not schedule a leaving time yet
	//					write get_current_date() + ": entered but its not first in queue on " + name;
						do add(vehicle, leave_date);
					}else{
						//case: there are some vehicle in front of us but we can overtake them (they are pedestrians or cyclists)
						leave_date <- get_current_date() add_seconds t_min;
						do add(vehicle, leave_date);
						do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
					}
				}	
			}
			default {
				write get_current_date() + ": " + name + " was not able to identify vehicle: "+ vehicle.name + "! " color:#red;
			}
		}
			
	}
	
	action propose(Vehicle vehicle){
		//this method is called by a source road (vehicle.current_road) to a target road
		if !empty(vehicle.my_path.edges) {
			Road next_road <- Road(vehicle.my_path.edges[0]);
			ask next_road {
				do treat_proposition(vehicle);
			}
		}else{
			//end of action
			ask vehicle {
				do arrive_at_destination;
			}
		}
	}
	
	action treat_proposition(Vehicle vehicle){
		if (current_capacity + vehicle.length <= max_capacity) or species(vehicle) = Feet or species(vehicle) = Bike {			
			do accept(vehicle);
		}else{			
			add vehicle to: waiting_list;
			vehicle.owner.color <- #orange;
			date t <- get_current_date() add_minutes deadlock_delay;
			do later the_action: "deadlock_prevention" with_arguments: map("vehicle"::vehicle) at: t;		
		}
	}
	
	action schedule_next_leaving_width_vehicle {
		loop v over: _queue {
			if species(v.key) = Car { //TODO add bus
				//next car leaving (pedestrian or bikes are not concerned) only the width-vehicles can not be schedule if they are not first in queue
				date leave_date <- v.value;
				
				if leave_date <= last_exit add_seconds outflow_delay {
					leave_date <- last_exit add_seconds outflow_delay + 1; //the +1 matters here (not sure why though)
				}
				if leave_date <= get_current_date() {
					leave_date <- get_current_date() add_seconds 1;
				}
				
				do later the_action: "propose" with_arguments: map("vehicle"::v.key) at: leave_date;
//				write get_current_date() + ": " + name + " schedules next " + v.key.name + " at " + leave_date color: #green;
				return;
			}
		}
	}
	
	action update_waiting_list {
		list<Vehicle> trash;
		//technically wa may have cases where we can accept a waiting car but that was not the first to register (like in a cross road section)
		loop e over: waiting_list {
			if (current_capacity + e.length <= max_capacity){
				do accept(e);
				add e to: trash;
			}
		}
		//cleaning the list
		loop t over: trash {
			remove t from: waiting_list;
		}
	}
	
	bool remove(Vehicle vehicle){
		//this method should be called by road target on road source
		int _idx <- 0; //we have to do it with an idex because queue is a pair.
		loop e over: _queue {
			if e.key = vehicle {
				current_capacity <- current_capacity - vehicle.length;
				last_exit <- get_current_date();
				remove index: _idx from: _queue;
				
				//update waiting_list and next leaving car since a new slot is free
				if species(vehicle) = Car { //TODO bus
					do schedule_next_leaving_width_vehicle;	
				}
				do later the_action: "update_waiting_list" at: get_current_date() add_seconds gap_travel_time;
//				write get_current_date() + " msg from remove fct, should be seen only once " + name color:#green;
				return true;
			}
			_idx <- _idx + 1;
		}
		write name + " was asked to remove " + vehicle.name + " but was not able to find it. This should not happen !" color:#red;
		return false;
	}
	
	action add(Vehicle vehicle, date leave_date){
		bool already_there <- check_presence(vehicle);
		if !(already_there){
//			do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
			//remove vehicle from its current road and add it to this road
			if vehicle.current_road != nil { //this happens if the vehicle is at its first road
				ask vehicle.current_road {
					bool _test <- remove(vehicle);	
					assert _test warning: true;
				}
			}
			ask vehicle{
				do enter_road(myself);
			}
			current_capacity <- current_capacity + vehicle.length;
			add pair(vehicle::leave_date) to: _queue;
			last_entry <- get_current_date();
		}else{
			write get_current_date() + ": " + name+ " tried to add " + vehicle.name + " but it was already in queue. This should not happen." color:#red;
		}
	}
	
	action deadlock_prevention(Vehicle vehicle) {
		//this method checks if a vehicle has been waiting a long time
		//TODO IMPORTANT: not coorect, avec ??a, le temps n'augmente pas correctement car on sera jamais au dessus de 1 en ratio capacity/max_capacity
		if waiting_list contains vehicle {
			write get_current_date() + ": " + vehicle.name + " is forcing its way on " + name color:#orange;
			float tmp_allocated_capacity <- vehicle.length + 0.01;
			max_capacity <- max_capacity + tmp_allocated_capacity;
			remove vehicle from: waiting_list ;
			do accept(vehicle);
			do later the_action: "remove_deadlock_capacity" with_arguments: map("tmp_allocated_capacity"::tmp_allocated_capacity) at: get_current_date() add_minutes 3;
		}
	}
	
	action remove_deadlock_capacity (float tmp_allocated_capacity) {
		//its better to always have the current_capacity below the max
		if current_capacity < max_capacity - tmp_allocated_capacity {
			max_capacity <- max_capacity - tmp_allocated_capacity;	
			max_tmp_alocated_test <- max_tmp_alocated_test + tmp_allocated_capacity; //TODO remove after test
		}else{
			do later the_action: "remove_deadlock_capacity" with_arguments: map("tmp_allocated_capacity"::tmp_allocated_capacity) at: get_current_date() add_minutes 3;
		}
	}
	
	bool check_presence(Vehicle vehicle){
		loop e over: _queue {
			if e.key = vehicle {
				return true;
			}
		}
		return false;
	}
	
	float compute_capacity_ratio_for_traffic {
		float r <- 0.0;
		loop e over: _queue {
			r <- r + e.key.traffic_influence * e.key.length;
		}
		return (r/max_capacity);
	}
	
	bool is_there_blocking_vehicle {
		loop e over: _queue {
			if species(e.key) = Car { //TODO add truck and bus
				return true;
			}
		}
		return false;
	}
	
	float get_theoretical_travel_time(Vehicle v){
		float speed <- min(max_speed, v.speed);
		return (shape.perimeter / speed);
	}
	
//	action auth_vehicles_init {
//		if auth_vehicles contains 0 {
//			car_track <- true;
//		}
//		if auth_vehicles contains 1 {
//			bike_track <- true;
//		}
//		if auth_vehicles contains 2 {
//			pedestrian_track <- true;
//		}
//		if auth_vehicles contains 3 {
//			car_track <- true;
//		}
//	}

	aspect default {
		draw displayed_shape color: rgb(255 * (current_capacity / max_capacity), 0, 0);
//		draw "" + length(_queue) + " " at: location + point([15, 15]) size: 10 color: #black;
	}

}

