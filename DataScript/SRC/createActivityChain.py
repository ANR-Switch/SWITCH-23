#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 22 13:06:47 2023

@author: flavien
"""

#df = pd.read_excel('/home/flavien/Documents/Alternance/Data/EnqueteMenageDeplacement/toulouse_2013_ori_depl.xls')

def create_activity(df):
    data = df.groupby(['ZFD','ECH','PER'],group_keys=True).agg({'D5A': lambda x: list(x),\
                                                                'D4': lambda x: list(x),\
                                                               }).reset_index()
    return data





"""df = create_activity(df)
#l = df.head().tolist()
#print (l)

print (df)
df.to_csv('/home/flavien/Documents/Alternance/Data/Traitement_emd/activity_chain.csv')
#[['tira','ech','per','d5']])"""
