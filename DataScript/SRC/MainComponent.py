
import networkx as nx
import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as pp
import os

def set_sources(r):
    if r['SENS']=='Sens direct':
        return r['geometry'].coords[0]
    elif (r['SENS']=='Sens inverse'):
        return r['geometry'].coords[-1]

def set_target(r):
    if r['SENS']=='Sens direct':
        return r['geometry'].coords[-1]
    elif (r['SENS']=='Sens inverse'):
        return r['geometry'].coords[0]

def largest_connected_component(gdf):
    
    double_sens = gdf[gdf['SENS']=='Double sens']
    sens_inverse = double_sens.copy()

    sens_inverse['SENS'] = 'Sens inverse'
    double_sens['SENS'] = 'Sens direct'

    gdf = pd.concat([gdf, sens_inverse, double_sens], ignore_index=True)
    gdf = gdf[gdf['SENS'] != 'Double sens']


    gdf['source'] = gdf.apply(lambda r : set_sources(r) ,axis=1)
    gdf['target'] = gdf.apply(lambda r : set_target(r) ,axis=1)
    #print(gdf['source'])
    # Extract edges from the 'geom' column
    
    G = nx.from_pandas_edgelist(gdf, 'source', 'target',create_using=nx.DiGraph())

    # Get connected components
    connected_components = list(nx.strongly_connected_components(G))
    

    # Find the largest connected component
    largest_component = max(connected_components, key=len)

    

    # Create a subgraph with the largest component
    largest_subgraph = G.subgraph(largest_component)

    """for edge in largest_subgraph.edges():
        node1,node2 = edge
        if not largest_subgraph.has_node(node1) or not largest_subgraph.has_node(node2):
            largest_subgraph.remove_edge(node1,node2)"""


    # Extract nodes of the largest subgraph
    largest_nodes = list(largest_subgraph.nodes())

    # Filter original GeoDataFrame to include only nodes from the largest subgraph
    largest_gdf = gdf[gdf['source'].isin(largest_nodes) & gdf['target'].isin(largest_nodes)]
    largest_gdf = largest_gdf.drop(columns=['source', 'target'])
    return largest_gdf




road = gpd.read_file("C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance4/roads.shp")
road = largest_connected_component(road)
road.to_file("C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance4/roads.shp")

"""for i in range (1,6):
    print ('process to create road : '+str(i))
    #os.mkdir("C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance"+str(i)+"/main_component")
    road = gpd.read_file("C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance"+str(i)+"/roads.shp")
    road = largest_connected_component(road)
    road.to_file("C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance"+str(i)+"/roads.shp")"""