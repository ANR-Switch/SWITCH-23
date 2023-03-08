/**
* Name: Profile
* Based on the internal empty template. 
* Author: coohauterv
* Tags: 
*/


model Profile

species Profile {
	int id;
	string description;
	string genre;
	int min_age;
	int max_age;
	list<int> professional_activities;
	int min_study;
	int max_study;
	int min_income;
	int max_income;
}

