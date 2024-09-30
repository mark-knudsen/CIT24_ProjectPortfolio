/*Creating table title*/
CREATE TABLE title
(
title_ID varchar(10) primary key,
title_type varchar(256),
primary_title text,
original_title text,
start_year numeric(4),
end_year numeric(4),
runtime numeric(6),
isadult boolean
);

/*Inserting data from tables title_basics to title*/
INSERT INTO title(title_ID, title_type, primary_title, original_title, start_year, end_year, runtime, isadult)
SELECT tconst, titletype, primarytitle, originaltitle, NULLIF(startyear, '')::NUMERIC, NULLIF(endyear, '')::NUMERIC, runtimeminutes, isadult
FROM title_basics


/*Creating table person*/
DROP TABLE IF EXISTS person CASCADE;
CREATE TABLE person
(
person_ID varchar(10) primary key,
primary_name varchar(256),
birth_year numeric(4),
death_year numeric(4)
);

/*insert data from tables name_basics to person*/
INSERT INTO person(person_ID, primary_name, birth_year,death_year) Select nconst, primaryname, NULLIF(birthyear, '')::NUMERIC, NULLIF(deathyear, '')::NUMERIC from name_basics


/*Create table profession*/
DROP TABLE IF EXISTS profession CASCADE;
CREATE TABLE profession
(
profession_ID serial NOT NULL UNIQUE, --Denne skal være NOT NULL UNIQUE, da vi i primaryproffession specificerer den som foreign key
profession varchar(256),
primary key (profession_ID, profession) 
);


/*Trimming name_basics.primaryprofession into atomic values and inserting into table profession*/

CREATE OR REPLACE FUNCTION atomize_and_populate_profession()
  RETURNS table(profession_id int, profession varchar) as  $BODY$
  declare longprofstring text;
  rec record;
begin
for rec in SELECT distinct primaryprofession from name_basics where regexp_like(primaryprofession, '\w')
LOOP
	longprofstring = concat(longprofstring, rec.primaryprofession, ',');
END LOOP; 
longprofstring = substr(longprofstring , 1, length(longprofstring) -1);
ALTER SEQUENCE profession_profession_id_seq RESTART WITH 1;

insert into profession(profession) 
SELECT distinct * from string_to_table(longprofstring, ',');

return query select * from profession ORDER BY profession_id asc;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE


/*creates primary_profession*/
DROP TABLE IF EXISTS primary_profession CASCADE;
CREATE TABLE primary_profession 
(
profession_ID int4, -- Change after non-atomized column primaryProfession has been corrected
person_ID varchar(10),
primary key (profession_ID, person_ID), 
foreign key(profession_ID) references profession (profession_ID),
foreign key(person_ID) references person (person_ID)
);


/*Populate primary_profession from name_basic using profession tables profession_id*/
CREATE OR REPLACE FUNCTION populate_primary_profession()
  RETURNS Table( id varchar, prof text)
	LANGUAGE plpgsql 
	as  $$
	declare rec record;
begin
drop table if exists tempPrimProf; --if previous temptable exist, drop it 
Create temp table tempPrimProf(pid varchar, primprof text); -- create new temptable
for rec in SELECT nconst, primaryprofession from name_basics -- for loop with select statement
LOOP
insert into tempPrimProf(pid, primprof) values (rec.nconst, unnest(string_to_array(rec.primaryprofession, ',')));  --populat temp table (an intermidiary step for debugging purposes, should be replaced with population below)
END LOOP; 
insert into primary_profession(profession_id, person_id) select profession_id, pid from tempPrimProf tpp, profession p where p.profession = primprof; -- populate from temp table to profession
-- the reason we are using temp tables is cause I was unable to write code that was able to do the "where EXISTS" check in the second exist as rec is a record and not a table which I can use select/from/where
return query select * from tempPrimProf; -- for debugging purposes, can be removed as long as return type is changed too
end;
$$

/*Creating most_relevant table*/
DROP TABLE IF EXISTS most_relevant CASCADE;
CREATE TABLE most_relevant
(
person_ID varchar(10),
title_ID varchar(10),
primary key (person_ID, title_ID),
foreign key (person_ID) references person (person_ID),
foreign key(title_ID) references title (title_ID) 
);

/*atomziation of data and subsequent population of table most_relevant*/
create or replace function atomize_and_populate_most_relevant()
RETURNS table(personid varchar, titleid varchar)
	LANGUAGE plpgsql 
	as  $$
	declare rec record;
begin 
drop table if exists outputTable; --this line has to be commented out before start, did not spend time figuring out a better way
create temp table outputTable(per_id varchar, tit_id varchar); -- create temp table
for rec in select nconst, knownfortitles from name_basics -- for each row returned from the select statement
LOOP	

insert into outputTable(per_id, tit_id) values (rec.nconst, unnest(string_to_array(rec.knownfortitles, ','))); --heres where the insert into temp table happens
END LOOP;
insert into most_relevant(person_id, title_id) select per_id, tit_id from outputTable where EXISTS(select tconst from title_basics where tconst = tit_id); -- and finally insert into the actual most_relevant table. 
-- the reason we are using temp tables is cause I was unable to write code that was able to do the "where EXISTS" check in the second exist as rec is a record and not a table which I can use select/from/where
return query select * from most_relevant; 
end;
$$


/*create genre_list table*/
DROP TABLE IF EXISTS genre_list CASCADE;
CREATE TABLE genre_list
(
genre_ID serial primary key,
genre varchar(256)
);


/*Trimming title_basics.genre into atomic and seperated values and inserting those in genre_list*/
CREATE OR REPLACE FUNCTION atomize_and_populate_genre_list()
  RETURNS table (id int, genre VARCHAR) as  $BODY$
  declare longgenrestring text;
  rec record;
begin
for rec in SELECT distinct genres from title_basics where regexp_like(genres, '\w')
LOOP
	longgenrestring = concat(longgenrestring, rec.genres, ',');
END LOOP; 
longgenrestring = substr(longgenrestring,  1, length(longgenrestring) -1);
ALTER SEQUENCE genre_list_genre_id_seq RESTART WITH 1;
insert into genre_list(genre) 
SELECT distinct * from string_to_table(longgenrestring, ',');

return query select * from genre_list;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE


/*create table title_genre*/
DROP TABLE IF EXISTS title_genre CASCADE;
CREATE TABLE title_genre
(
genre_ID SMALLINT,
title_ID varchar(10),

primary key (title_ID, genre_ID),
foreign key (title_ID) references title (title_ID),
foreign key (genre_ID) references genre_list(genre_ID)
);

/*atomize and popuate genres from title_basics into table title_genre*/

create or replace function atomize_and_populate_title_genre()
RETURNS table(genreid int2, titleid varchar)
	LANGUAGE plpgsql 
	as  $$
	declare rec record;
begin 
drop table if exists outputTable;
create temp table outputTable(tit_id varchar, genre varchar);
for rec in select tconst, genres from title_basics
LOOP	

insert into outputTable(tit_id, genre) values (rec.tconst, unnest(string_to_array(rec.genres, ',')));
END LOOP;

insert into title_genre(genre_id, title_id) select genre_list.genre_ID, tit_id from outputTable, genre_list where outputTable.genre = genre_list.genre;
return query select * from title_genre; 
end;
$$


/*create table principal_cast*/

CREATE TABLE principal_cast 
(
person_ID varchar(10),
ordering numeric(2),
title_ID varchar(10),
character_name text,
category varchar(50),
job text,

primary key (person_ID, title_ID, ordering),
foreign key (title_ID) references title (title_ID),
foreign key (person_ID) references person (person_ID)
);

/*Insert from title_principals into principal_cast*/
insert into principal_cast(person_ID, ordering, title_ID, character_name, category, job) 
select title_principals.nconst, ordering, title_principals.tconst, characters, category, job 
from title_principals, title_basics, name_basics 
where title_basics.tconst = title_principals.tconst AND name_basics.nconst = title_principals.nconst;

/*create table rating*/

CREATE TABLE rating
(
title_ID varchar(10) primary key,
average_rating numeric(3,1), ---Ændret denne til 3,1, da man ellers kun kan vise max 9.9
vote_count numeric(7),
foreign key (title_ID) references title (title_ID)
);

/*insert data into rating from title_ratings*/
insert into rating(title_ID, average_rating, vote_count) 
select title_ratings.tconst, averagerating, numvotes 
from title_ratings, title_basics 
where title_basics.tconst = title_ratings.tconst



/*create table word_index */
DROP TABLE IF EXISTS word_index CASCADE;
CREATE TABLE word_index
(
title_ID varchar(10),
word text,
field char(1),
lexeme text,

primary key (title_ID, word, field),
foreign key (title_ID) references title (title_ID)

);


/*insert data into word_index from wi table*/
insert into word_index(title_ID, word, field, lexeme) select wi.tconst, wi.word, wi.field, wi.lexeme from wi, title_basics where title_basics.tconst = wi.tconst



/*Creating table Plot*/
DROP TABLE IF EXISTS plot CASCADE;
CREATE TABLE plot
(
title_ID varchar(10) primary key,
plot TEXT
);

/*Inserting data from field in OMDB_Data called"plot" to Plot*/
INSERT INTO plot(title_ID, plot) SELECT tconst, plot FROM omdb_data WHERE plot != 'N/A' AND plot IS NOT NULL 

/*Creating table Poster*/
DROP TABLE IF EXISTS poster CASCADE;
CREATE TABLE poster
(
title_ID varchar(10) primary key,
poster text,
foreign key (title_ID) references title (title_ID)
);

/*Inserting data from field in OMDB_Data called "Poster" to Poster*/
INSERT INTO poster(title_ID, poster) SELECT tconst, poster FROM omdb_data WHERE poster != 'N/A' AND poster IS NOT NULL 

/*Creating table episode_from_series*/
DROP TABLE IF EXISTS episode_from_series CASCADE;
CREATE TABLE episode_from_series
(
title_ID varchar(10),
series_title_ID varchar(10),
season_num numeric(2),
episode_num numeric (4),

primary key (title_ID, series_title_ID),
foreign key (title_ID) references title (title_ID),
foreign key (series_title_ID) references title (title_ID)

);

/*Inserting data from title_episode to episode_from_series*/
INSERT INTO episode_from_series(title_ID, series_title_ID, season_num, episode_num) SELECT tconst, parenttconst, seasonnumber, episodenumber FROM title_episode


/*Creating table localized_title */
DROP TABLE IF EXISTS localized_title CASCADE;
CREATE TABLE localized_title
(
localized_ID serial UNIQUE,
title_ID varchar(10),
ordering numeric(3), -- dvs localized ID bliver unik for hver title_ID + ordering combination


primary key (localized_ID, title_ID, ordering),
foreign key (title_ID) references title (title_ID)
);

ALTER SEQUENCE localized_title_localized_ID_seq RESTART WITH 1;
/*Inserting data from title_akas to localized_title, excluding titles present in title_akas that has 't' attribute in "isoriginaltitle" column. Aka excluding original titles */
INSERT INTO localized_title(title_ID, ordering) SELECT titleid, ordering FROM title_akas WHERE isoriginaltitle IS FALSE; 


/*Creating table localized_detail*/
DROP TABLE IF EXISTS localized_detail CASCADE;
CREATE TABLE localized_detail
(
localized_ID INT4 primary key,
localized_title text,
language varchar(10),
region varchar(10),
type varchar(256),
attribute varchar(256),

foreign key (localized_ID) references localized_title (localized_ID)
); 

select * from localized_detail where localized_title = 'Twin Peaks'

/*Inserting data from title_akas and localized_title to localized_detail*/
INSERT INTO localized_detail(localized_ID, localized_title, language, region, type, attribute) SELECT lt.localized_ID, taka.title, taka.language, taka.region, taka.types, taka.attributes 
FROM localized_title as lt
JOIN title_akas taka ON lt.title_ID = taka.titleid AND lt.ordering = taka.ordering 
 
 
 
