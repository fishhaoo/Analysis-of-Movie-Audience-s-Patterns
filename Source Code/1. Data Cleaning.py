# -*- coding: utf-8 -*-
"""
Created on Sun Nov 15 15:07:01 2020

@author: shama
"""

#import libraries
import pandas as pd

#MOVIES

Movies = pd.read_csv("movies.dat",sep="::",names=["MovieID","Title","Genres"]
                     ,engine='python')

# Rows containing duplicate data
duplicate_rows_Movies = Movies[Movies.duplicated()]
print("number of duplicate rows:", duplicate_rows_Movies.shape)
# Finding the null values.
print(Movies.isnull().sum())


#RATINGS

# Import Ratings Dataset 
Ratings = pd.read_csv("ratings.dat",sep="::",names=["UserID","MovieID"
                                                    ,"Rating","Timestamp"]
                                                    ,engine='python')


# Rows containing duplicate data
duplicate_rows_Ratings = Ratings[Ratings.duplicated()]
print("number of duplicate rows:", duplicate_rows_Ratings.shape)
# Finding the null values.
print(Ratings.isnull().sum())

#USERS

# Import Users Dataset

Users = pd.read_csv("users.dat",sep="::",names=["UserID","Gender","Age",
                                                "Occupation","Zip-code"]
                                                ,engine='python')

# Rows containing duplicate data
duplicate_rows_dfUsers = Users[Users.duplicated()]
print("number of duplicate rows:", duplicate_rows_Ratings.shape)
# Finding the null values.
print(Users.isnull().sum())




