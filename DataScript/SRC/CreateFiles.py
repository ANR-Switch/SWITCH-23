#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 25 16:21:40 2023

@author: flavien
"""
import PrepaDataWShabou as shabou
import CentroidandSphere as CS
import FormatRoute as fr

import pandas as pd
import geopandas as gpd
import os
import random
import ast

src_ppl = '../IN/toulouse_2013_std_pers.csv'
dst_ppl = '../OUT/People.csv'

src_depl = '../IN/toulouse_2013_std_depl.csv'
dst_depl = '../OUT/depl.csv'

src_road = '../IN/TRONCON_DE_ROUTE.shp'
dst_road = '../OUT/road.shp'

#/home/flavien/Documents/Alternance/data/Carte/roadTopo/BDTOPO_3-3_TOUSTHEMES_SHP_LAMB93_D031_2023-03-15/BDTOPO/1_DONNEES_LIVRAISON_2023-03-00212/BDT_3-3_SHP_LAMB93_D031-ED2023-03-15/BATI/BATIMENT.shp'
src_bati = '../IN/BATIMENT.shp'
dst_bati = '../OUT/bati.shp'

population_model = '../OUT/populationModel.csv'

population = '../OUT/population.csv'

out_path = '../OUT'

in_path = '../IN'

def one_of(l):
    actis = ast.literal_eval(l['D5A'])
    times = ast.literal_eval(l['D4'])
    
    i = random.randint(0,len(l)-1)
    #print(l[i])
    return actis[i],times[i]

def set_activities(r):
    r['activities'],r['depart'] = one_of(pop_model.loc[r['profile']])
    
    
    return r


print('Initiating file creation script')
if(not os.path.exists(out_path)):
   os.mkdir(out_path)
if(not os.path.exists(in_path)):
   os.mkdir(in_path)

if(not os.path.exists(dst_ppl)):
    print('create EMD classified people file')
    shabou.createPeople(src_ppl,dst_ppl)
    print('create activity file')
    shabou.createActivityChain(src_depl, dst_depl)
    
    ppl = pd.read_csv(dst_ppl)
    depl = pd.read_csv(dst_depl)

    
elif(not os.path.exists(dst_depl)):
    print('create activity file')
    shabou.createActivityChain(src_depl, dst_depl)
    ppl = pd.read_csv(dst_ppl)
    depl = pd.read_csv(dst_depl)


if(not os.path.exists(population_model)):
    print('create modele file')
    ppl = pd.read_csv(dst_ppl)
    depl = pd.read_csv(dst_depl)
    shabou.createModelPopulation(ppl, depl, population_model)
    pop_model = pd.read_csv(population_model)

else :
    print('read population files')
    ppl = pd.read_csv(dst_ppl)
    depl = pd.read_csv(dst_depl)
    pop_model = pd.read_csv(population_model)

if(not os.path.exists(population)):
    print('create new population with model')
    pop_model.set_index(['profile'],inplace=True)

    pop = ppl.apply(lambda r: set_activities(r),axis=1)
    pop = pop.drop(axis=1,labels='Unnamed: 0')
    pop.to_csv(population)   
else:
    print('population dont change')
    pop = pd.read_csv(population)


if(not os.path.exists(dst_road)):
    print('creating roads')
    road = gpd.read_file(src_road)
    road = CS.intersectCercle(road)
    road = fr.format_route_direct(road)
    road.to_file(dst_road)
else :
    print('roads dont change')


if(not os.path.exists(dst_bati)):
    print('creating bati')
    bati = gpd.read_file(src_bati)
    bati = CS.intersectCercle(bati)
    bati = CS.normalise_bati_topo(bati)
    bati.to_file(dst_bati)
else:
    print('bati dont change')
"""if(not os.path.exists(dst_road)):
    if not os.path.exist(src_road_agglo):
        print('creating agglo map')
        fr.loc_road(src_road_region,src_road_agglo)
    print('formating agglo road map')
    fr.format_road(src_road_agglo,dst_road)

"""