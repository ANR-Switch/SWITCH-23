import geopandas as gpd


#['Route à 1 chaussée' 'Chemin' 'Route empierrée' 'Rond-point' 'Sentier'
# 'Route à 2 chaussées' 'Bretelle' 'Type autoroutier' 'Escalier'
# 'Bac ou liaison maritime']

lane_dict = {
    'Route à 1 chaussée' : 1,
    'Chemin': 1,
    'Route empierrée': 1,
    'Rond-point': 2,
    'Sentier': 1 ,
    'Route à 2 chaussées': 2,
    'Bretelle': 2,
    'Type autoroutier': 3,
    'Escalier': 1,
    'Bac ou liaison maritime': 1

}

df = gpd.read_file('c:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance6')
df.loc[df['NB_VOIES']==0,'NB_VOIES'] = df['NATURE'].map(lane_dict).fillna(1)
print (df.head())
#df0
df.to_file('C:/Users/flavi/Travail/Switch-23/DataScript/Test/road.shp')



#df['NB_VOIES'].fillna(1,inplace = True)
#print(df)
