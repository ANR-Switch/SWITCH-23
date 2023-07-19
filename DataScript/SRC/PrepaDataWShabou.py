#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 25 10:23:27 2023

@author: flavien
"""
import pandas as pd

import Classify_Shabou as cp
import createActivityChain as ac


def createProfileList(r) :
    ret = []
    for e in r:
        i = 0
        found = False
        while(i<len(ret) and not found):
            if(e == ret[i][0]):
                found = True
                ret[i][1] += 1
            i +=1
        if(not found):
            ret.append([e,1])
    """i=0
    while(i<len(chain)):
        if(proba[i]<=1):
            del chain[i]
            del proba[i]
        else:
            i+=1"""
    return ret

def createPeople(src,dst):
    print('create new people file')
    ppl = pd.read_csv(src,sep=';',header=0)
    ppl['people_in_foy'] = 0
    foy_count = ppl.groupby(['ZFP','ECH'],group_keys=True)['people_in_foy'].count()
    ppl = ppl.drop(['people_in_foy'],axis=1)
    ppl = ppl.merge(foy_count, on=['ZFP','ECH'])
    ppl = cp.classify_people(ppl)
    ppl.to_csv(dst)
#print(ppl)

def createActivityChain(src,dst):
    print('create new deplacement chain file')
    depl= pd.read_csv(src,sep=';',header=0)
    depl = ac.create_activity(depl)
    depl.to_csv(dst,index=True)

def createModelPopulation(ppl,depl,dst):
    print('create new population model file')
    df = ppl.merge(depl,on=['ECH','PER'])
    df = df.groupby(['profile']).agg({'D5A': lambda x: list(x),\
                                     'D4': lambda x: list(x),\
                                }).reset_index()#.to_frame()
    #df.set_index("profile",inplace=True)
    df.to_csv(dst,index=True)



