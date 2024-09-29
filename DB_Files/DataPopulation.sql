/*Creating table Title*/
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

/*Inserting data from title_basics to title*/
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

/*Inserting data from name_basics to person*/
INSERT INTO person(person_ID, primary_name, birth_year,death_year) Select nconst, primaryname, NULLIF(birthyear, '')::NUMERIC, NULLIF(deathyear, '')::NUMERIC from name_basics


/*Create table profession*/
DROP TABLE IF EXISTS profession CASCADE;
CREATE TABLE profession
(
profession_ID serial NOT NULL UNIQUE, --Denne skal være NOT NULL UNIQUE, da vi i primaryproffession specificerer den som foreign key
profession varchar(256),
primary key (profession_ID, profession) 
);


/*Trimming name_basics.primaryprofession into atomic and seperated values*/

CREATE OR REPLACE FUNCTION profession_trim()
  RETURNS table(profession_id int, profession varchar) as  $BODY$
  declare longprofstring text;
  rec record;
begin
for rec in SELECT distinct primaryprofession from name_basics
LOOP
	longprofstring = concat(longprofstring, rec.primaryprofession, ', ');
END LOOP; 
ALTER SEQUENCE profession_profession_id_seq RESTART WITH 1;

insert into profession(profession) 
SELECT distinct * from string_to_table(longprofstring, ',');

return query select * from profession ORDER BY profession_id asc;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE

/*call this for profession_trim()*/
SELECT distinct * from profession_trim();



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


/*atomize and populate primary_profession*/
CREATE OR REPLACE FUNCTION atomize_and_populate_primary_profession()
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
create or replace function atomize_and_populate_mostknownfor()
RETURNS table(personid varchar, titleid varchar)
	LANGUAGE plpgsql 
	as  $$
	declare rec record;
	declare temp_kft VARCHAR;
	declare temp_kft1 VARCHAR;
	declare temp_kft2 VARCHAR;
begin 
drop table outputTable; --this line has to be commented out before start, did not spend time figuring out a better way
create temp table outputTable(per_id varchar, tit_id varchar); -- create temp table
for rec in select nconst, knownfortitles from name_basics -- for each row returned from the select statement
LOOP	
	temp_kft = split_part(rec.knownfortitles, ',', 1); -- inserting knownfortitles first commaseperated value in to the temp_kft, since there is a max of 3 knownfortitles there are three variables
	temp_kft1 = split_part(rec.knownfortitles, ',', 2);
	temp_kft2 = split_part(rec.knownfortitles, ',', 3);
insert into outputTable(per_id, tit_id) values (rec.nconst, unnest(string_to_array(rec.knownfortitles, ','))); --heres where the insert into temp table happens
END LOOP;
insert into most_relevant(person_id, title_id) select per_id, tit_id from outputTable where EXISTS(select tconst from title_basics where tconst = tit_id); -- and finally insert into the actual most_relevant table. 
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



/*Trimming title_basics.genre into atomic and seperated values*/
CREATE OR REPLACE FUNCTION atomize_and_populate_genres()
  RETURNS table (id int, genre VARCHAR) as  $BODY$
  declare longgenrestring text;
  rec record;
begin
for rec in SELECT distinct genres from title_basics
LOOP
	longgenrestring  = concat(longgenrestring, rec.genres, ', ');
END LOOP; 

ALTER SEQUENCE genre_list_genre_id_seq RESTART WITH 1;
insert into genre_list(genre) 
SELECT distinct * from string_to_table(longgenrestring, ',');

return query select * from genre_list;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE

-- run genres_trim()
select * from atomize_and_populate_genres()

