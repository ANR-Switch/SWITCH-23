#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 22 14:00:01 2023

@author: flavien
"""

import geopandas as gpd
from shapely.geometry import Point
import FormatRoute as fr 
import formatageBati as fb

def normalise_bati_topo (df):
    newdf = gpd.GeoDataFrame(columns=['id', 'type', 'name', 'geometry'], geometry='geometry')
    newdf['id'] = df['ID']
    newdf['geometry'] = df['geometry']
    newdf['type'] = df.apply(lambda r: fb.class_bati_Topo(r['USAGE1']),axis=1)
    return newdf
    
def normalise_bati_osm (df):
    df['type'] = df.apply(lambda r: fb.class_bati_OSM(r['type']),axis=1)
    return df

communes = '/home/flavien/Documents/Alternance/data/Carte/roadTopo/BDTOPO_3-3_TOUSTHEMES_SHP_LAMB93_D031_2023-03-15/BDTOPO/1_DONNEES_LIVRAISON_2023-03-00212/BDT_3-3_SHP_LAMB93_D031-ED2023-03-15/ADMINISTRATIF/COMMUNE.shp'

#src_bati = '/home/flavien/Documents/Alternance/data/Carte/Dijon/SRC/BATIMENT.shp'
#dst_bati = '/home/flavien/Documents/Alternance/data/Carte/Dijon/DST/bati.shp'


#src_route = '/home/flavien/Documents/Alternance/data/Carte/Dijon/SRC/TRONCON_DE_ROUTE.shp'
#dst_route = '/home/flavien/Documents/Alternance/data/Carte/Dijon/DST/road.shp'

communes = gpd.read_file(communes)
toulouse = communes.loc[communes['INSEE_COM']=="31555"]
center = toulouse.centroid
center_point = Point(center.x,center.y)
circle = center_point.buffer(10000)
crs = communes.crs


def intersectCercle(carte):
    carte = carte.to_crs(crs)
    carte = carte.reset_index(drop=True)
    carte = carte[carte.geometry.is_valid]
    carte = carte[carte.intersects(circle,align=False)]
    return carte

"""
route = fr.format_route_direct(route)
route.to_file(dst_route)


bati = normalise_bati_topo(bati)
bati.to_file(dst_bati)
"""