import pandas as pd
import geopandas as gpd

residualFlowGeom = gpd.read_file("C:/Users/flavi/Travail/Switch-23/includes/tests/roadImportance1/INOUT.shp")
print(residualFlowGeom)
residualFlowMatrix = pd.read_csv("C:/Users/flavi/Travail/Switch-23//includes/tests/RoadImportance1NC/Matrices_OD.csv")
print(residualFlowMatrix.to_string())

gdf = residualFlowGeom.merge(residualFlowMatrix)
print(gdf)
#df = gpd.concat([residualFlowGeom,residualFlowMatrix],axis=1)
#df = df.drop(columns=df.columns[df.columns.duplicated()])
#print(df)
gdf.to_file("C:/Users/flavi/Travail/Switch-23/includes/tests/INOUT.shp")