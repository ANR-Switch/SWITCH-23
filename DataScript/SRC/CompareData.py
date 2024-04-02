#!/usr/bin/env python3
# -*- coding: utf-8 -*-Users
"""
Created on 26/02/2024

@author: flavien
"""


import geopandas as gpd
import pandas as pd
import numpy as np
"""
roads = ['A61','A62','A64','A68']
for i in roads:
    for j in roads:
        if i != j:
            gama_file = pd.read_csv("C:/Users/flavi/Travail/Switch-23/models/logs_file/lateness"+i+j+".csv")
            print (gama_file)
            gama_file = gama_file.groupby(['ID'],group_keys=True).agg({
                                                                    
                                                                        "distance": lambda x: sum(x),\
                                                                        "duration": lambda x: sum(x),\
                                                                        "mean speed":lambda x: np.mean(x),\
                                                                        "start" : lambda x:list(np.unique(x)),\
                                                                        "dest" : lambda x:list(np.unique(x)),\
                                                                        "road's topo id" : lambda x:list(x)\
                                                                        })
            print (gama_file)
            gama_file.to_csv("C:/Users/flavi/Travail/Switch-23/models/logs_file/traited_"+i+j+".csv")



 #road's topo id":lambda x: list(x),"
 """

df = pd.read_csv("C:/Users/flavi/Travail/Switch-23/models/logs_file/AllRoad.csv")
road = gpd.read_file("C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance2/roads.shp")


#largest_gdf = gdf[gdf['source'].isin(largest_nodes) & gdf['target'].isin(largest_nodes)]
print (df['roads'][1])
print(road['ID'])
traject = road[road['ID'] == (df['roads'][1])]
print(traject) 