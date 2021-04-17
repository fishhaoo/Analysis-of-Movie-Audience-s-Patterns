/* READ RATINGS DATASET*/
data ratings;
	infile '/home/u48446390/ahmed/ratings.dat' dlmstr='::' 
		encoding=wlatin1;
	input UserID MovieID Rating TimeStamp;
run;

*READ MOVIES DATASET;
data movies;
infile '/home/u48446390/ahmed/movies.dat' dlmstr='::' encoding=wlatin1;
length name $ 90 Genre $ 50;
input MovieId Name $ Genre $;
run;

*MANIPULATING MOVIES DATASET AND SPLITTING GENRE;
data movies2;
set work.movies;
array g $15 g1-g5 ;
do i=1 to dim(g);
g{i} = scan(Genre, i, '|'); /* Splitting Genre*/
if g{1} in ('Action', 'Adventure', 'Animation', "Children's", 'Comedy', 'Crime', 'Documentary', 'Drama', 'Fantasy', 'Film-Noir', 'Horror',
			'Musical', 'Mystery', 'Romance', 'Sci-Fi', 'Thriller', 'War', 'Western') 
				then do; 
					g{i} = g{i}; 
					end;
end; /* seperate genres individually*/
Year = scan (name, -1);/*extract the years of the movies*/
Year = compress(Year, '()');
X=_n_;
drop i x ;
run;

*READ USERS; 

data users; DATASET
	infile '/home/u48446390/ahmed/users.dat' dlm='::';
	length ZipCode $ 10;
	input UserID Gender $ Age Occupation ZipCode $;
run;



/* Sort Rating dataset*/

proc sort data=work.ratings;
by UserID;
run;
/* Sort users dataset/*/

proc sort data=work.users;
by UserID;
run;

/* combine ratings and users datasets*/
data userratings;
merge work.ratings work.users;
by UserID;
run;

* sorting userRatings dataset to allow us to combine it with Movies;
proc sort data=work.userratings;
by MovieId;
run;

/* combine the sorted usersRatings with movies*/
data usermovieratings;
merge work.userratings work.movies2;
by MovieID;
drop TimeStamp ZipCode Gender Occupation Genre name Year; /*drop those which u felt is not in use*/
run;



*****************************************************************************************************;
*Running ANOVA test for UsersRating dataset;

Title "ANOVA test for Ratings and Age Groups";
ods noproctitle;
ods graphics / imagemap=on;

proc glm data=WORK.USERRATINGS plots(only)=(boxplot 
		diagnostics);
	class Age;
	model Rating=Age;
	means Age / hovtest=levene welch plots=none;
	lsmeans Age / adjust=tukey pdiff alpha=.05 plots=(meanplot diffplot);
	run;
quit;


*Finding the Frequency of users and movie ratings using PROC FREQ;
proc freq data=userratings;
	tables age * rating;
run;

*Generating Correlation test for userRatings;

PROC CORR DATA=work.userratings;
    VAR Age;
    WITH Rating;
RUN;

/*anova for boxplot*/
ods graphics on;
proc glm data=main.comb plot(only maxpoints=100000000)=(ancovaplot boxplot);
	class rating Age;
	model rating = Age;
	lsmeans genre / adjust=tukey;
	means genre / hovtest=levene;
run;


*********************************************************************;
* To investigate the favourite genre in each age group;

*proc sql to get the count of the top genre in the given age groups;
proc sql;
create table topag1 as
select *
from (select genre, Age, count(*) as cnt from main.ag1 group by genre)
having cnt=max(cnt);
quit;

proc sql;
create table topag18 as
select *
from (select genre, Age, count(*) as cnt from main.ag18 group by genre)
having cnt=max(cnt);
quit;

proc sql;
create table topag25 as
select *
from (select genre, Age, count(*) as cnt from main.ag25 group by genre)
having cnt=max(cnt);
quit;

proc sql;
create table topag35 as
select *
from (select genre, Age, count(*) as cnt from main.ag35 group by genre)
having cnt=max(cnt);
quit;

proc sql;
create table topag45 as
select *
from (select genre, Age, count(*) as cnt from main.ag45 group by genre)
having cnt=max(cnt);
quit;

proc sql;
create table topag50 as
select *
from (select genre, Age, count(*) as cnt from main.ag50 group by genre)
having cnt=max(cnt);
quit;

proc sql;
create table topag56 as
select *
from (select genre, Age, count(*) as cnt from main.ag56 group by genre)
having cnt=max(cnt);
quit;

data topgva;
set topag1 topag18 topag25 topag35 topag45 topag50 topag56;
run;

proc template;
define style styles.mystyle;
parent=styles.listing;
style GraphDataText from GraphDataText /
fontsize=18pt;
end;
run;

*plotting of the bar chart;
ods html style=tyle;
PROC SGPLOT DATA = topgva;
title 'The top genre reviewed by each age group counted in frequency';
VBAR age /
datalabel = genre;
RUN;

*********************************************************************;
* Vizualization to see the distribution of genres in each age group;
* extracting all the genres in g1, g2, g3, g4, g5 by age group;
data g1(rename=(g1=genre));
set usermovieratings;
keep g1 Age;
run;

data g2(rename=(g2=genre));
set usermovieratings;
if g2 = " " then delete;
keep g2 Age;
run;

data g3(rename=(g3=genre));
set usermovieratings;
if g3 = " " then delete;
keep g3 Age;
run;

data g4(rename=(g4=genre));
set usermovieratings;
if g4 = " " then delete;
keep g4 Age;
run;

data g5(rename=(g5=genre));
set usermovieratings;
if g5 = " " then delete;
keep g5 Age;
run;

*combine all into 1 dataset for genres vs age;
data genres;
set g1 g2 g3 g4 g5;
run;

*split the genres by age;
data main.ag1 main.ag18 main.ag25 main.ag35 main.ag45 main.ag50 main.ag56;
set genres;
if Age = 1 then output main.ag1;
	else if Age = 18 then output main.ag18;
		else if Age = 25 then output main.ag25;
			else if Age = 35 then output main.ag35;
				else if Age = 45 then output main.ag45;
					else if Age = 50 then output main.ag50;
						else if Age = 56 then output main.ag56;
run; 

*proc template for the styling of the pie chart;
PROC TEMPLATE;
   DEFINE STATGRAPH pie;
      BEGINGRAPH;
         LAYOUT REGION;
            PIECHART CATEGORY = genre /
            DATALABELLOCATION = INSIDE
            DATALABELCONTENT = ALL
            CATEGORYDIRECTION = CLOCKWISE
            DATASKIN = SHEEN 
            START = 180 NAME = 'pie';
            DISCRETELEGEND 'pie' /;
         ENDLAYOUT;
      ENDGRAPH;
   END;
RUN;

*plotting of the pie chart of favourite genres in each age group;
PROC SGRENDER DATA = main.ag1
            TEMPLATE = pie;
            title 'Genres Ditribution for age group - 1';
RUN;

PROC SGRENDER DATA = main.ag18
            TEMPLATE = pie;
            title 'Genres Ditribution for age group - 18';
RUN;

PROC SGRENDER DATA = main.ag25
            TEMPLATE = pie;
            title 'Genres Distributions for age group - 25';
RUN;

PROC SGRENDER DATA = main.ag35
            TEMPLATE = pie;
            title 'Genres Ditribution for age group - 35';
RUN;

PROC SGRENDER DATA = main.ag45
            TEMPLATE = pie;
            title 'Genres Ditribution for age group - 45';
RUN;

PROC SGRENDER DATA = main.ag50
            TEMPLATE = pie;
            title 'Genres Distributions for age group - 50';
RUN;

PROC SGRENDER DATA = main.ag56
            TEMPLATE = pie;
            title 'Genres Distributions for age group - 56';
RUN;


*Generating Correlation test for userRatings;

PROC CORR DATA=work.userratings;
    VAR Age;
    WITH Rating;
RUN;









