#!/usr/bin/env python3
# -*- coding:
#utf-8 -*-
"""
Created on Wed May  3 15:
28:
55 2023

@author:
 flavien
"""

import geopandas as gpd


def class_bati_OSM(e):
    #print(e)
    match e:
        case "industrial":
            return 1
        case 'shed':
            return 1 #hangar
        case 'hangar':
             return 1
        case 'hospital':
            return 4
        case 'service':
            return 4
        case 'garage':
            return 1
        case 'garages':
            return 1
        case 'school':
            return 2
        case 'yesschool':
            return 2
        case 'roof':
            return 0 #???
        case 'office':
            return 1
        case 'transportation':
            return -1
        case 'church':
	        return 9
        case 'industrial':
            return 1
        case 'commercial':
            return 3
        case 'garage':
	        return  1
        case 'civic':
	        return 4
        case 'public':
	        return 4
        case 'university':
            return 2
        case 'college':
            return 2
        case 'retail':
	        return 3# commerce
        case 'carports':
            return -1 #???
        case 'carport':
            return -1 #???
        case 'hotel':
	         return 0
        case 'manufacture':
            return 1
        case 'ruins':
            return 9 #???
        case 'sports_centre' :
            return 5
        case 'sports_centreyes':
            return 5
        case 'sports_hall':
            return 5
        case 'sport':
            return 5
        case 'warehouse':
            return 1 #entrepot
        case 'chapel':
            return 9
        case 'kindergarten':
            return 2
        case 'storage_tank':
            return 1
        case 'farm_auxiliary' :
            return 1
        case 'terrace':
            return 5
        case 'transformer_tower':
            return -1
        case 'fire_station' :
            return 1
        case 'stadium':
            return 5
        case 'kiosk':
            return 5
        case 'shelter':
            return 9
        case 'barn':
            return 1 # grange
        case 'shop':
            return 3
        case 'parking':
            return 9
        case 'bridge':
            return 9
        case 'supermarket':
            return 3
        case 'greenhouse':
            return 1 #serre
        case 'water_tower':
            return 9
        case 'government':
            return 4
        case 'train_station':
            return 1
        case 'cathedral':
            return 9
        case 'theatre':
            return 5
        case 'convent':
            return 9 #couvent
        case 'marketplace':
            return 3
        case 'synagogue':
            return 9
        case 'laboratory':
            return 1
        case 'dovecote':
            return 9
        case 'school_gymansium' :
            return 2
        case 'farm':
	        return 1
        case 'grandstand':
            return 5 #Tribune de gymnase
        case 'silo':
            return 1
        case 'monastery':
            return 9
        case 'temple':
            return 9
        case 'castle':
            return 0
        case 'religious':
            return 9
        case 'mosque':
            return 9
        case 'riding_hall':
            return 5 #cheval
        case 'post_office':
            return 4
        case 'restaurant':
            return 5
        case 'inverter':
            return 1
        case 'container':
            return 1
        case 'observatoire':
            return 5
        case 'cloister':
            return 9 #religion
        case 'stable':
            return 5 #ecurie
        case _ :
            return 0
        
        
def class_bati_Topo(e):
   # ['Indifférencié', 'Résidentiel', 'Commercial et services', 'Sportif', 'Religieux', 'Industriel', 'Annexe', 'Agricole']
    match e :
        case 'Indifférencié':
            return 0
        case 'Résidentiel':
            return 0
        case 'Commercial et services' :
            return 5
        case 'Sportif' :
            return 5
        case 'Religieux':
            return 9
        case 'Industriel':
            return 1
        case 'Annexe':
            return 9
        case 'Agricole':
            return 1
     
"""df = gpd.read_file('/home/flavien/Documents/Alternance/data/Carte/Dijon/SRC/BATIMENT.shp')
print(df.columns)"""