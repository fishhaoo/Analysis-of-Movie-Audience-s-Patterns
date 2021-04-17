*Research Q2: List of movies that fall under the upper quartile of the ratings;
*read the rating file and sort it based on MovieID;

data ratings;
	infile '/home/u47506320/sasuser.v94/Assignment/ratings.dat' dlmstr='::' 
		encoding=wlatin1;
	input UserID MovieID Rating TimeStamp;
run;

proc sort data=ratings;
	by MovieID;
run;

*read the users file;

data users;
	infile '/home/u47506320/sasuser.v94/Assignment/users.dat' dlm='::';
	length ZipCode $ 10;
	input UserID Gender $ Age Occupation ZipCode $;
run;

*read the movies file;

data movies;
	infile '/home/u47506320/sasuser.v94/Assignment/movies.dat' dlmstr='::' 
		encoding=wlatin1;
	length name $ 90 Genre $ 50;
	input MovieID Name $ Genre $;
run;

***********************************************************************************************
*Merging of datasets ratings and movies;

data ratingsMovie;
	merge ratings movies;
	by MovieID;
run;

***********************************************************************************************;
*median, 1st Quartile, 3 Quartile and std dev of rating;

proc means data=ratings median q1 q3 stddev;
	var rating;
run;

*List of movies that fall under the upper quartile of the ratings;
proc sql;
	create table ratingsSorted as select Distinct (Name), MovieID , avg(rating) as 
		average_rating, count (distinct UserID) as Number_of_Users_who_rated from 
		ratingsMovie group by MovieID having avg(rating) ge 4;
	*order by movieID;
quit;

proc print data=ratingsSorted;
run;

***********************************************************************************************
*Merging all 3 db;
*Redundant data of all movies ge 4;

proc sql;
	create table ratingsCombined as select Name, UserID, MovieID, avg(rating) as 
		average_rating from ratingsMovie group by MovieID having avg(rating) ge 4;
quit;

*Sorting ratingsCombined by UserID;

proc sort data=ratingsCombined;
	by UserID;
run;

*Merging db ratingsCombined and Users;

data movieCombined;
	merge ratingsCombined Users;
	by UserID;
run;

***********************************************************************************************

*Subquestion: Gender breakdown of the users who rated the movies that averaged more than 4.0

*Pie Chart Representation;
goptions reset=all border;
title 'Gender breakdown by User Ratings*';
footnote '*Users who had rated the movies that had an average rating of greater than or equal to 4';
proc gchart data=movieCombined(where=(gender='F' or gender='M'));
	pie gender / percent=inside plabel=(height=20pt) slice=inside;
	run;
quit;

*Extract the year value from the dataset & convert it to a numeric val;

data ratingsSorted;
	set ratingsSorted;
	Year=scan (name, -1);

	YearNum=input(Year, 8.);
	drop Year;
	rename YearNum = Year;
run;

*Run a regression model for the average rating * year;

proc reg data=ratingsSorted;
	model average_rating=Year;
	run;
	
