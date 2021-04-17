# -*- coding: utf-8 -*-
"""
Created on Wed Nov  4 21:07:20 2020

@author: shama
"""
#import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from wordcloud import WordCloud, STOPWORDS #used to generate world cloud


#GENERAL DATA EXPLORATION

#MOVIES

Movies = pd.read_csv("movies.dat",sep="::",names=["MovieID","Title","Genres"]
                     ,engine='python')

# Used to count the number of rows
Movies.count()
#Info of the Movies dataset includes indication if there are null values and 
#the Pandas data type
Movies.info()
# HEAD() displays the first five rows, first five index values
Movies.head()
# TAIL() To display the bottom 5 rows
Movies.tail()


#RATINGS

# Import Ratings Dataset 
Ratings = pd.read_csv("ratings.dat",sep="::",names=["UserID","MovieID",
                                                    "Rating","Timestamp"],
                      engine='python')

#Used to count the number of rows in Ratings
Ratings.count()
#Info of the Ratings dataset includes indication if there are null values and 
#the Pandas data type
Ratings.info()
# HEAD() displays the first five rows, first five index values
Ratings.head()
# TAIL() To display the bottom 5 rows
Ratings.tail()

#Summary statistic of ratings
Ratings.describe()

#Minimum Rating given to a movie
Ratings['Rating'].min()
#Maximum rating given to a movie
Ratings['Rating'].max()



#USERS

Users = pd.read_csv("users.dat",sep="::",names=["UserID","Gender","Age",
                                                "Occupation","Zip-code"],
                    engine='python')

#Used to count the number of rows in Ratings
Users.count()
#Info of the Users dataset includes indication if there are null values and 
#the Pandas data type
Users.info()
# head() displays the first five rows, first five index values, of every 
#column within a Pandas data frame object.
Users.head()
# tail() To display the bottom 5 rows
Users.tail()

#################################################################################################################

#Merging of dataset

# Merging of the Movies and Ratings datasets

MovieRatings = Movies.merge(Ratings,on='MovieID',how='inner')
MovieRatings.head()

# to count the number of rows and collumns in the merged dataset
MovieRatings.shape

# Merging of the MovieRatings and Users datasets 

MasterDataset = MovieRatings.merge(Users,on="UserID",how='inner')
MasterDataset.head()

#Generating a csv file for the master dataset with all 3 datasets combined
MasterDataset.to_csv("CombinedDataset.csv")

#################################################################################################################

#Movies Data Visualization

#1. Splitting the genre

#Splitting of the genre
#Counting of the number of times the specific genre appears

def genre_repetition(df, ref_col, liste):
    genre_count = dict()
    for s in liste: genre_count[s] = 0
    for liste_keywords in df[ref_col].str.split('|'):
        if type(liste_keywords) == float and pd.isnull(liste_keywords):continue
        for s in liste_keywords: 
            if pd.notnull(s): genre_count[s] += 1
    # convert the dictionary in a list to sort the keywords  by frequency
    genre_num = []
    for k,v in genre_count.items():
        genre_num.append([k,v])
    genre_num.sort(key = lambda x:x[1], reverse = True)
    return genre_num, genre_count

#Making a list of all the occurance of genre
genre_title = set()
for s in Movies['Genres'].str.split('|').values:
    genre_title = genre_title.union(set(s))
    
#Making a list of the counted total of genre occurance
genre_num, dum = genre_repetition(Movies, 'Genres', genre_title)
genre_num


#2. Creating the Word Cloud

#WORD CLOUD

#Finally, the result is shown as a wordcloud:

distinct_genre = dict()
genre_occurences = genre_num[0:50]
for s in genre_occurences:
    distinct_genre[s[0]] = s[1]
#To define the colour 
tone = 100 
f, ax = plt.subplots(figsize=(14, 6))
wordcloud = WordCloud(width=550,height=300, background_color='white', 
                      max_words=1628,relative_scaling=0.7, 
                      normalize_plurals=False)

#Generate the word cloud based on the distinct genre
wordcloud.generate_from_frequencies(distinct_genre)

#Defining the specifics of the wordcloud
#interpolation="bilinear" is added to make the displayed image appear smoother
plt.imshow(wordcloud, interpolation="bilinear")
plt.axis('off')
plt.show()


#3 User Age Distribution


# To count the number of users based on the specific age group
MasterDataset['Age'].value_counts()


# Plot for users with different age groups
#Defining the values required, colour and the axes titles
MasterDataset['Age'].value_counts().plot(kind='bar', color = 'purple',
                                         figsize = (8,7))
plt.xlabel("Age")
plt.title("User Age Distribution")
plt.ylabel('Users Count')
plt.show()


#3.Sample movie and ratings breakdown
#Chosen movie is Jumanji (1995)

#Indicating to the system to filter out Jumanji alone.
JumanjiRating = MasterDataset[MasterDataset['Title'].str.contains('Jumanji') == True]
JumanjiRating

#Grouping the output the Title and the Rating
JumanjiRating.groupby(["Title","Rating"]).size()

JumanjiRating.groupby(["Title","Rating"]).size().unstack().plot(kind='barh',stacked=False,legend=True)
plt.show()



#4. Listing out the 10 most popular films based on the number of times it has been rated

Popular25Films = MasterDataset.groupby('Title').size().sort_values(ascending=False)[:10]
Popular25Films

Popular25Films.plot(kind='barh',alpha=0.6,figsize=(7,7), color ='purple')
plt.xlabel("Ratings Count")
plt.ylabel("Movies (Top 10)")
plt.title("Top 10 Most Rated film")
plt.show()


#5. Identifying the ratings for all the movies that UserID = 4827 has reviewed

userId = 4827
userRatingById = MasterDataset[MasterDataset["UserID"] == userId]
userRatingById
