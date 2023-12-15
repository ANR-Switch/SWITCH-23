import ast
import geopandas as gpd
import os
import pandas as pd
import matplotlib.pyplot as plt

df = gpd.read_file("C:/Users/flavi/Travail/Switch-23/DataScript/Test/roads.shp") #C:/Users/flavi/Travail/Switch-23/DataScript/Test
tab = []
max = int(df['IMPORTANCE'].max())
for i in range(1,max+1):
    i = str(i)
    tab.append(i)
    print(tab)
    df2 = df.loc[df['IMPORTANCE'].isin(tab)]
    print(df.head())
    df2.to_file('C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance'+i+"/roads.shp")
    #df2.plot()
    #plt.show()