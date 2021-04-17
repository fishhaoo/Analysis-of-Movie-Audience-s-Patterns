libname main '/home/u47506320/sr/Assignment';

/** movies DATA Manipulation **/
*step 1: orginal file, used for loading and not edit;
data movies;
infile '/home/u47506320/sasuser.v94/Assignment/movies.dat' dlmstr='::' encoding=wlatin1;
length name $ 90 Genre $ 50;
input MovieId Name $ Genre $;
run;

*step 2 : results;
data main.movies;
set movies;
array g $15 g1-g5 ;
do i=1 to dim(g);
g{i} = scan(Genre, i, '|');
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

/** loading RATINGS Dataset **/
data main.ratings;
infile '/home/u47506320/sasuser.v94/Assignment/ratings.dat' dlmstr ='::';
input UserID MovieID Rating TimeStamp;
run;


/* loading Users Dataset */
data main.users;
infile '/home/u47506320/sasuser.v94/Assignment/users.dat' dlmstr='::' encoding=wlatin1;
length ZipCode $ 10;
input UserID Gender $ Age Occupation ZipCode $;
run;

*Sort ratings dataset;

proc sort data=main.ratings;
	by MovieID;
run;

*Merge ratings and movies;

data movieRatings;
	merge main.ratings main.movies;
	by MovieID;
run;

*Sort movieRatings dataset;

proc sort data=movieRatings;
	by UserID;
run;

*Merge movieRatings and User dataset;

data MovieCombined;
	merge movieRatings main.users;
	by UserID;
run;

