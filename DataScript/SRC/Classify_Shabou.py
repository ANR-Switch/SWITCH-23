#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 22 15:19:25 2023

@author: flavien
"""
import pandas as pd
import createActivityChain as ac


    

def classify(r):
    #age = r['p4']
    if r['P9']==1 or r['P9']==2:                #working
        if r['P2']==1:                              #male
            if r['PCSD']>=61 and r['PCSD']<=69:           #laborer
                return 1
            else :                                      #farmer, artisant, traders, manager, professors, employees, retired
                if r['people_in_foy'] >= 3: # householde                          #parent   
                    return 2
                else:                                      #Single or without children
                    return 3
                                                 
        else:                                      #female
            if r['people_in_foy'] <=2: #household                            #single, no children
                return 4
            else:                                       #parent
                if r['P8']==5 or r['P8']==6:                #diploma > bac
                    return 5
                else:                                       #diploam <= bac
                    return 6
    else:                                       #not working
        if r['P9']==3 or r['P9']==4 :              #student
            return 7
        elif r['P9'] == 5 :                        #schoolchild
            return 8
        else :                                     #retired, unemployed, houswife...
            if r['P4']>60:                              #age > 60
                if r['P2']==1:                              #male
                    return 9
                else :                                      #female
                    return 10
            else :                                      #age < 60
                if r['P9']==8:                              #housewife / househusband
                    return 11
                else :                                      #retired
                    return 12
        
        
    

def classify_people(df):
    df['profile'] = df.apply(lambda r: classify(r),axis=1)
    return df
    


























