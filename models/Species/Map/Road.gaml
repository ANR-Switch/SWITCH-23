/*
* Name: Road
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/

model Road

import "../../Utilities/Constants.gaml"

import "../Vehicles/Vehicle.gaml"


species Road skills: [scheduling] schedules: [] {
	string topo_id;
	int lanes; //From shapefile 
	float max_speed ;//<- 50.0 #km/#h; // From shapefile //must be then transformed in m/s
	string oneway <- "no"; //From shapefile
	string allowed_vehicles;
	point trans <- {2.0, 2.0};
	geometry displayed_shape;
	rgb color <- #black;
	int importance;
	bool main_comp <- false;
	string nature ;
	
	
	//identifiers
	bool car_track <- false;
	bool bike_track <- false;
	bool pedestrian_track <- false;
	bool public_transport_track <- false;	
	
	//traffic attributes
	float base_capacity <-shape.perimeter#m * lanes;
	float current_capacity <- 0.0;
	float max_capacity <- base_capacity;
	float alpha <- Constants[0].alpha;
	float beta <- Constants[0].beta;
	float speed_factor <- Constants[0].speed_factor;
	date last_entry;
	date last_exit;
	float inflow_delay;
	float outflow_delay;
	float gap_travel_time <- shape.perimeter / 5 ; 
	int deadlock_patience <- Constants[0].deadlock_patience; //minutes to try to force the car inside the road
	list<pair<Vehicle, date>> _queue; //queue is a build-in name so we use _queue TODO: use a map ?
	list<Vehicle> waiting_list;
	
	
	int comptage;
	int lateness;
	
	
	//Graph :
	//graph car_road_graph;
	//graph feet_road_graph;
	//graph bike_road_graph;
	
	//test
	float max_tmp_alocated_test;
	int entry_counter_ <- 0;	
	Logger log;
	int self_forced;
	int inflow;
	int outflow;
	int accepted;
	int daily_frequentation <- 0;
	int fail <- 0;
	int ratio_blocked <-0;
	int blocked <-0;
	//output display
	bool is_jammed <- false;
	bool is_highlight <- false;
	bool had_to_increase_capacity <- false;

	init {
		point A <- first(shape.points);
		point B <- last(shape.points);
		if (A = B) or (B.x = A.x) { //I added the second condition to avoid errors
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
		
		if lanes = nil or lanes = 0 {
			lanes <- 1;
		}
		
		displayed_shape <- (shape + lanes) translated_by (trans * 2);
		
		/*if (importance=1){
			max_speed <- max_speed-10;
		}*/
		
		/*//some security checks
		if max_speed = nil {
			write name + " dies because of no maxspeed" color:#red;
			do die;
		}
		if allowed_vehicles = nil {
			write name + " dies because of no allowed vehicles" color:#red;
			do die;
		}else{*/
			do allowed_vehicles_init();
		//}
		if max_speed < 5 { //walking speed
			max_speed <- 5.0;
		}
		if max_capacity < 1 {
			max_capacity <- 1.0;
		}
		if max_capacity < Constants[0].minimum_road_capacity_required and car_track {
			max_capacity <- Constants[0].minimum_road_capacity_required;
			had_to_increase_capacity <- true;
			//write name + " defines the minimum max_capacity value." color:#orange;
		}
		
		
		//todo if the speed in the shapefile is in km/h
		//necessary because the speed of the vehicle is automatically set to m/s
		float speed <- max_speed/3.6;
		max_speed <- speed #m/#s;
		
		/*if topo_id = 'TRONROUT0000000073494421'{
			do die;
		}*/
		
	
	}
	
	float compute_time{
		//write shape.perimeter / max_speed ;
		return shape.perimeter / max_speed ;
		
	}
	
	action init_delay{
		outflow_delay <- 2.0;
		inflow_delay <- 2.0;
		
		if (nature!="Type autoroutier" 	and nature!="Bretelle"){
			if(lanes = 2 ){
				alpha <- 0.73;
				beta <- 1.38;
			}else if (lanes = 3 ){
				alpha <- 0.63;
				beta <- 1.58;
			}else{
				alpha <- 0.8;
				beta <- 1.28;
			}
			
		}else{
			alpha <- 1.1;
			beta <- 1.25;
		}
		/*if ( length(topology(self) neighbors_of(self)) > 2){
			outflow_delay <- 2.0/lanes;
			inflow_delay <- 2.0/lanes;
		}
		else{
			outflow_delay <- 2.0/(lanes*2);
			inflow_delay <- 2.0/(lanes*2);
		}
		
		if (nature!="Type autoroutier" 	and nature!="Bretelle"){
			if(lanes = 2 ){
				alpha <- 0.73;
				beta <- 1.38;
			}else if (lanes = 3 ){
				alpha <- 0.63;
				beta <- 1.58;
			}else{
				alpha <- 0.8;
				beta <- 1.28;
			}
			
		}else{
			alpha <- 1.1;
			beta <- 1.25;
		}
		
			/*if (nature!="Type autoroutier" 	and nature!="Bretelle"){
				if ( length(topology(self) neighbors_of(self)) > 2){
					inflow_delay <- 1.5;
					outflow_delay <- 1.5;
				}else{
					inflow_delay <- 1.0;
					outflow_delay <- 1.0;
				}
			}
			else{
				inflow_delay <- 2.0;
				outflow_delay <- 2.0;
			}*/
			
		}
		

	
	action log_capacity{
		ask log{do log(myself.topo_id+" capacity : "+myself.max_capacity);}
	}
	
	action accept(Vehicle vehicle){
		//accepted <- accepted +1;
		date leave_date;
		float speed <- min(vehicle.speed, max_speed);
		float t_min <- ceil(shape.perimeter / speed);//minimum time spent on the road
//		if(t_min < 1.0){
//			t_min <- 1.0;
//		}  //TODO COMMENT ?
		

		switch species(vehicle){
			match Bike {
				leave_date <- get_current_date() add_seconds t_min;
				do add(vehicle, leave_date);
				msg_sent <- msg_sent+1;
				do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
			}
			match Feet {
				leave_date <- get_current_date() add_seconds t_min;
				do add(vehicle, leave_date);
				msg_sent <- msg_sent+1;
				do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
			}
			match_one [Car,ResidualVehicle] {
				t_min <- t_min / speed_factor;
			
				if empty(_queue){
					//case: the vehicle can only go out if it's the first in queue
					leave_date <- get_current_date() add_seconds t_min;
					do add(vehicle, leave_date);
					
					do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
				}else{
					//case: is there a non overtakable vehicle in front of us ?
					//bool blocked <- is_there_blocking_vehicle();
	
					if is_there_blocking_vehicle() {
						float capacity_ratio <- compute_capacity_ratio_for_traffic();
						//float t <- t_min * ( 1 + alpha * capacity_ratio ^ beta ); //TODO retry
						float t <- t_min;
						leave_date <- get_current_date() add_seconds t;
						//case: we do not schedule a leaving time yet
						do add(vehicle, leave_date);
					}else{
						//case: there are some vehicle in front of us but we can overtake them (they are pedestrians or cyclists)
						leave_date <- get_current_date() add_seconds t_min;
						do add(vehicle, leave_date);
						
						do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
					}
				}	
			}
			match Bus {
				t_min <- t_min / speed_factor;
				if empty(_queue){
					//case: the vehicle can only go out if it's the first in queue
					leave_date <- get_current_date() add_seconds t_min;
					do add(vehicle, leave_date);
					msg_sent <- msg_sent+1;
					do later the_action: "propose" with_arguments: map("vehicle"::vehicle) at: leave_date;
				}else{
					//case: is there a non overtakable vehicle in front of us ?
					bool _bool <- is_there_blocking_vehicle();
	
					if _bool {
						float capacity_ratio <- compute_capacity_ratio_for_traffic();
						float t <- t_min * ( 1 + alpha * capacity_ratio ^ beta );
						leave_date <- get_current_date() add_seconds t;
						//case: we do not schedule a leaving time yet
						do add(vehicle, leave_date);
					}else{
						//case: there are some vehicle in front of us but we can overtake them (they are pedestrians or cyclists)
						leave_date <- get_current_date() add_seconds t_min;
						do add(vehicle, leave_date);
						msg_sent <- msg_sent+1;
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
		//write "propose";
		
		//this method is called by a source road (vehicle.current_road) to a target road
		/*if species(vehicle) = Bus {
			Bus b <- Bus(vehicle);
			if !empty(b.my_roads) {
				Road next_road <- b.my_roads[0];
				ask next_road {
					do treat_proposition(vehicle);
				}
			}else{
				//end of action
				ask vehicle {
					do arrive_at_destination;
				}
			}
		}else{*/
			if !empty(vehicle.my_path.edges) {
				//write "path not empty";
				Road next_road <- Road(vehicle.my_path.edges[0]);
				ask next_road {
					do treat_proposition(vehicle);
				}
			}else{
				//end of action
				ask vehicle {
					//write "arrive at destination";
					do arrive_at_destination;
				}
			}	
		//}
	}
	
	action treat_proposition(Vehicle vehicle){
		
		
		if (current_capacity + vehicle.length <= max_capacity) or species(vehicle) = Feet or species(vehicle) = Bike {			
			do accept(vehicle);
		}else{			
			add vehicle to: waiting_list;
			vehicle.owner.color <- #orange;
			is_jammed <- true;
			date t <- get_current_date() add_seconds deadlock_patience;
			//msg_sent <- msg_sent+1;
			do later the_action: "deadlock_prevention" with_arguments: map("vehicle"::vehicle) at: t;		
		}
	}
	
	action schedule_next_leaving_width_vehicle { //TODO ???
		loop v over: _queue {
			if species(v.key) = Car or species(v.key) = Bus { 
				//next car leaving (pedestrian or bikes are not concerned) only the width-vehicles can not be schedule if they are not first in queue
				date leave_date <- v.value;
				
				//here last_exit is like get_current_date()
				if leave_date < self.last_exit add_seconds outflow_delay {
					leave_date <- self.last_exit add_seconds outflow_delay ; //the +1 matters here (not sure why though)
				}
				msg_sent <- msg_sent+1;
				do later the_action: "propose" with_arguments: map("vehicle"::v.key) at: leave_date;
				return; //TODO BREAK ?
			}
		}
	}
	
	action update_waiting_list {
		//technically wa may have cases where we can accept a waiting car but that was not the first to register (like in a cross road section)
		//list<Vehicle> trash;
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
		if empty(waiting_list) {
			is_jammed <- false;
		}
		 
		 
		 
//		loop e over: waiting_list {
//			if (current_capacity + e.length <= max_capacity){
//				do accept(e);
//				remove e from: waiting_list;
//			}
//		}
//	
//		if empty(waiting_list) {
//			is_jammed <- false;
//		}
	}
	
	bool remove(Vehicle vehicle){
//		//max_capacity <- base_capacity;
//		//this method should be called by road target on road source
		int _idx <- 0; //we have to do it with an idex because queue is a list of pair.
		loop e over: _queue {
			if e.key = vehicle {
				//outflow <- outflow+1;
				current_capacity <- current_capacity - vehicle.length;
				color <- rgb(255 * (current_capacity / max_capacity), 0, 0);
				last_exit <- get_current_date();
				remove index:_idx from: _queue;
//				
//				//update waiting_list and next leaving car since a new slot is free
				if species(vehicle) = Car or species(vehicle) = Bus{ 
					do schedule_next_leaving_width_vehicle;	
				}
//				
				do later the_action: "update_waiting_list" at: get_current_date() add_seconds gap_travel_time; //TODO ???
////				write get_current_date() + " msg from remove fct, should be seen only once " + name color:#green;
				return true;
			}
			_idx <- _idx + 1;
		}
//		write name + " was asked to remove " + vehicle.name + " but was not able to find it. This should not happen !" color:#red;
		return false;
	}
	
	action add(Vehicle vehicle, date leave_date){
		/*if(verboseTravel){
			write get_current_date() + ": " +vehicle.name+" enter : "+name;
		}*/
		
		daily_frequentation <- daily_frequentation+1;
		
		bool already_there <- check_presence(vehicle);
		if !(already_there){
			//remove vehicle from its current road and add it to this road
			if vehicle.current_road != nil { //this happens if the vehicle is at its first road
				ask vehicle.current_road {
					
					bool _test <- remove(vehicle);	
					assert _test warning: true;
				}
			}
			ask vehicle{
				do enter_road(myself);
				if myself.topo_id="TRONROUT0000000073486729" and (length(path_list)) < 20{
					add self.my_path.shape to:path_list; 
				}
			}
			current_capacity <- current_capacity + vehicle.length;
			
			color <- rgb(255 * (current_capacity / max_capacity), 0, 0);
			add pair(vehicle::leave_date) to: _queue;
			last_entry <- get_current_date();
			entry_counter_ <- entry_counter_ + 1;
		}else{
			write get_current_date() + ": " + name+ " tried to add " + vehicle.name + " but it was already in queue. This should not happen." color:#red;
		}
	}
	
	action deadlock_prevention(Vehicle vehicle) {
		
		//this method checks if a vehicle has been waiting a long time
		//TODO IMPORTANT: not coorect, avec ça, le temps n'augmente pas correctement car on sera jamais au dessus de 1 en ratio capacity/max_capacity
		if waiting_list contains vehicle {
			is_jammed <- true;
			self_forced <- self_forced+1;
			
			/*try{
				ask vehicle.current_road { remove index: 0 from: _queue;}
				}catch{
					write "deadlock remove failed";
					fail <- fail+1;
				}*/
			if forcing < 1 {
				add self to:forcedRoad;
			}
			if countForcing{
					forcing <- forcing+1;
				}
			if current_capacity < 2 * max_capacity {
				
				
				if(verboseRoadForcing){
					ask log{ do log (myself.get_current_date() + ": " + vehicle.name + " is forcing its way on " + myself.topo_id );}
				}
				
				float tmp_allocated_capacity <- vehicle.length + 0.01;
				//max_tmp_alocated_test <- max_tmp_alocated_test + tmp_allocated_capacity; //TODO remove after test
				
				ratio_blocked <- ratio_blocked+1;
				
				max_capacity <- max_capacity + tmp_allocated_capacity;
				
				remove vehicle from:waiting_list ;
				do accept(vehicle);
				msg_sent <- msg_sent+1;
				do later the_action: "remove_deadlock_capacity" with_arguments: map("tmp_allocated_capacity"::tmp_allocated_capacity) at: get_current_date() add_minutes deadlock_patience;
				//ratio_blocked <- ratio_blocked-1;
			}else{
				//try again later
				//we do this to prevent having the current_capacity above 10 times the max_capacity, which can quickly happen with deadlocks
				date t <- get_current_date() add_minutes deadlock_patience;
				do later the_action: "deadlock_prevention" with_arguments: map("vehicle"::vehicle) at: t;
			}	
		}
	}
	
	action remove_deadlock_capacity (float tmp_allocated_capacity) {
		
		//its better to always have the current_capacity below the max
		if current_capacity < max_capacity - tmp_allocated_capacity {
			ratio_blocked <- ratio_blocked-1;
			max_capacity <- max_capacity - tmp_allocated_capacity;	
			is_jammed <- false;
		}else{
			do later the_action: "remove_deadlock_capacity" with_arguments: map("tmp_allocated_capacity"::tmp_allocated_capacity) at: get_current_date() add_minutes deadlock_patience;
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
		return min([1,(r/max_capacity)]);
	}
	
	bool is_there_blocking_vehicle {
		loop e over: _queue {
			if species(e.key) = Car or species(e.key) = Bus {
				return true;
			}
		}
		return false;
	}
	
	float get_theoretical_travel_time(Vehicle v){
		float speed <- min(max_speed, v.speed);
		if species(v) = Car or species(v) = Bus { 
			return  (shape.perimeter / speed) / speed_factor;
		}else{
			return (shape.perimeter / speed);	
		}
	}
	
	float get_capacity_ratio {
		return current_capacity/max_capacity;
	}
	
	action allowed_vehicles_init {
		if allowed_vehicles contains "0" {
			car_track <- true;
		}
		if allowed_vehicles contains "1" {
			bike_track <- true;
		}
		if allowed_vehicles contains "2" {
			pedestrian_track <- true;
		}
		if allowed_vehicles contains "3" {
			public_transport_track <- true;
		}
		
		//colors
		if !car_track and !public_transport_track {
			color <- #darkgoldenrod;
		}
	}
	action log_frenquency {
		if self_forced > 0{
			ask log{do log(myself.topo_id+' day frequetation : '+ myself.daily_frequentation+'\n\t forced : '+myself.self_forced+' times.');}
		}
		
	}
	
	action log_end{
		if blocked > 0 {
			ask log {do log(myself.topo_id+" get blocked : "+myself.blocked +" block - unblock : "+myself.ratio_blocked);}
		}
	}
	
	action log_event{
		
	}
	
	action write_log{
		
	}

	aspect default {
		draw displayed_shape color: color;
	}

}

