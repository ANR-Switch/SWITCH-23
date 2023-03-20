/**
* Name: NewModel
* Based on the internal empty template. 
* Author: flavien
* Tags: 
*/


model Population_builder

import "../World.gaml"

import "../Species/Activities/Profile.gaml"

import "../Species/Activities/Agenda.gaml"

import "../Species/Activities/Activity.gaml"

import "../Species/Person.gaml"


species Population_builder schedules: [] {
	string bdd <- "../../includes/DataSet/Switch_old.db";									//Path to the database
	map<string, string>  param <- ['dbtype'::'sqlite','database'::bdd];		//Setings of the database
	
	//useful param to pass for building population
	date sim_starting_date; 
	//
	
	//utility function return true if tested value is between min_value and max_value
	bool between(int tested_value, int min_value, int max_value){
		return (tested_value>=min_value and tested_value<=max_value);
	}
	
	//utility function return true if the element is in the list
	bool is_in(int looking_for,list<int> l){
		loop element over:l {
			if element=looking_for{
				return true;
			}
		}
		return false;
	}
	
	
	//utility function return true if the individue i corespond to the profile p
	bool check_profile (Profile p, Person i){
		return between(i.age,p.min_age,p.max_age) and 
		between(i.income,p.min_income,p.max_income) and
		between(i.study_level,p.min_study,p.max_study) and
		(i.genre=p.genre or p.genre='a' or i.genre = 'a') and
		is_in(i.professional_activity,p.professional_activities) and
		p.id != 0;
	}
	
	//function set all the profile correpsonding to each profile
	action link_indiv_profile{
		loop i over: Person{
			loop p over: Profile{
				if(check_profile(p,i)){
					add item:p.id to:i.profile;
				}
			}
			if i.profile = []{
				i.profile <- [0];
			}
		}
	}
	
	//create all the individu in the db and all other agents needed to create individu
	action create_agent_with_bdd{
		create database {										//use database specie to link to db
			
			create Profile from: (self.select(params: myself.param,	//first, create all the profile
				select: "SELECT * FROM profile"))
				with:[id::"id_profile",description::"nom",genre::"genre",min_income::"revenu_min",
					max_income::"revenu_max",min_age::"age_min",max_age::"age_max",
					professional_activities::"activite_pro",min_study::"etude_min",max_study::"etude_max"
				];
				
			////	
			
			loop i from: 0 to: 0 {
			create Person from: (self.select(params: myself.param,	//create all the individu
				select: "SELECT * FROM individu"))
				with:[first_name::"nom",age::"age",genre::"genre",professional_activity::"activite_pro",income::"revenu",study_level::"etudes"];
			}
			
			
			create Agenda from: (self.select(params: myself.param,		//create all the agent
				select: "SELECT * FROM agenda"))
				with:[id::"id_agenda",name::"nom"];
			
				list tmp;	
				loop a over: Agenda{										//for all agenda 
					create Activity from: (self.select(params: myself.param,	//create activities coresponding of each agenda
						select: "SELECT * FROM activite, agenda, agenda_activite
								WHERE agenda.id_agenda = "+a.id+
								" AND agenda.id_agenda = agenda_activite.id_agenda
								 AND agenda_activite.id_activite = activite.id_activite"))
						with:[id::"id_activite",title::"nom",priority_level::"priorite",type::"type",starting_minute::"heure_de_debut",duration::"duree"] returns:listA;
						a.activities <- listA;					//add those activities to the agenda
				
				tmp <- (self.select(params: myself.param,					//select all profile coresponding to the agenda
							select: "SELECT id_profile FROM profile_agenda, agenda
									WHERE profile_agenda.id_agenda = agenda.id_agenda
									AND profile_agenda.id_agenda = "+a.id
				))[2];
					
				loop id_profile over:tmp{						//for all profile found
					
				add item:int(id_profile[0]) to: a.profile;	//add profiles to agenda
				
				}
			}
		}	
	}
	
	//select agenda for all individu of the simulation
//	action link_indiv_agenda{
//		loop i over: Person{
//			ask i {
//				do select_agenda;
//			}
//		}
//	}
	
	action set_all_buildings{
		loop ppl over: Person{
			ask ppl {
				living_building <- select_building(living_buildings);
				location <- any_location_in(living_building);
				current_building <- living_building;
				working_building <- select_building(working_buildings);
				studying_building <- select_building(studying_buildings);
				commercial_building <- select_building(commercial_buildings);
				leasure_building <- select_building(leasure_buildings);
			}
		}
	}
	
	action set_all_vehicles {
		loop ppl over: Person {
			ask ppl {
				do choose_vehicle;
			}
		}
	}
	
	action set_all_agendas{
		loop ppl over: Person{
			ask ppl {
				do select_agenda;
			}
		}
	}
	
	action set_all_persons_activities{
		loop ppl over: Person{
			loop a over:ppl.personal_agenda.activities{
				ask a {					
					do set_starting_date(myself.sim_starting_date);
//					do choose_location(myself.living_buildings, myself.working_buildings);						
				}
			}
//			ask ppl {
//				do salt_agenda;
//			}
		}
	}
	
	action register_all_first_activities {
		loop ppl over: Person {
			ask ppl {
				do register_first_activity;
			}
		}
	}
	
//	init{ //AVOID INIT, it cause problems of synchronoicity
////		assert length(living_buildings) > 0;
////		do initialize_population;
//	}
	//initilize alle the agent of the simulation
	action initialize_population{
		do create_agent_with_bdd ;
		do link_indiv_profile;
		do set_all_buildings;
		do set_all_vehicles;
		do set_all_agendas;
		do set_all_persons_activities;
//		do register_all_first_activities; has to be done after linking them to a manager so in world.gaml
	}
}


species database skills: [SQLSKILL]{}

