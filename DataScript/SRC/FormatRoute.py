#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May  3 16:40:00 2023

@author: flavien
"""
import geopandas as gpd

def loc_road(src, dst):
    df = gpd.read_file(src)#'/home/flavien/Documents/Alternance/data/Carte/roadTopo/TRONCON_DE_ROUTE.shp'
    tab = ['31003','31022','31032','31044','31053','31056','31069','31088','31091', \
           '31116','31149','31150','31157','31163', '31182','31184','31186','31205','31230' \
            '31282','31293','31351','31352','31355','31389','31417','31418','31445','31488'\
            '31490','31506','31541','31555','31557','31561','31588']
    df = df.loc[df['INSEECOM_G'].isin(tab | df['INSEECOM_D'].isin(tab))]
    df.to_file(dst)#'/home/flavien/Documents/Alternance/data/Carte/OSMToulouse/formatedData/routeMetropoleToulouse.shp'

def set_vehicule(r):
    ret = []
    if(r['ACCES_VL']!='Physiquement impossible'):           #Vehicule leger
        ret.append(0)
    if(r['CYCLABLE_G']!='' or r['CYCLABLE_D']!=''):  #Velo
        ret.append(1)
    if(r['ACCES_PED']!=''):                             #Pieton
        ret.append(2)
    if(r['BUS']!=''):                                   #Bus
        ret.append(3)
    if ret==[]:
        ret = [2]
    return ' '.join([str(elem) for elem in ret])


def format_road(src, dst):   
    df = gpd.read_file(src)#'/home/flavien/Documents/Alternance/data/Carte/OSMToulouse/formatedData/routeMetropoleToulouse.shp'
    df['NB_VOIES'].fillna(1,inplace = True)
    df.fillna('',inplace=True)
    df['VEHICULES'] = df.apply(lambda r: set_vehicule(r),axis=1)
    df = df[['ID','NATURE','IMPORTANCE','NB_VOIES','SENS','VIT_MOY_VL','LARGEUR','VEHICULES','geometry']]
    #df['NB_VOIES'].fillna(1, inplace = True)
    #df['NB_VOIES'] = df.apply(lambda r : check_voies(r),axis=1)
    
    df.to_file(dst)#'/home/flavien/Documents/Alternance/data/Carte/OSMToulouse/formatedData/RouteMetropoleFormate.shp'

def format_route_direct(route):
    route['NB_VOIES'].fillna(1,inplace = True)
    route.fillna('',inplace=True)
    route['VEHICULES'] = route.apply(lambda r: set_vehicule(r),axis=1)
    route = route[['ID','NATURE','IMPORTANCE','NB_VOIES','SENS','VIT_MOY_VL','LARGEUR','VEHICULES','geometry']]
    return route


df = gpd.read_file("C:/Users/flavi/Travail/Switch-23/DataScript/IN/roads.shp")#'/home/flavien/Documents/Alternance/data/Carte/OSMToulouse/formatedData/routeMetropoleToulouse.shp'
#road = format_route_direct(df)

df = df.loc[df['IMPORTANCE'] == '1']
df.to_file("C:/Users/flavi/Travail/Switch-23/DataScript/OUT/roads1.shp")
#df.loc[df['column_name'] == some_value]