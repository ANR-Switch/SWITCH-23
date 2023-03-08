/**
* Name: agenda
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model agenda

import "../Person.gaml"

import "Activity.gaml"

species Agenda schedules: [] {
	string name;
	int id;
	Person owner;
	list<int> profile;
	list<Activity> activities;
}
