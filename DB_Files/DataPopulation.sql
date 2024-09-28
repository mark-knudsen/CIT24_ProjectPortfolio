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
  RETURNS setof TEXT as  $BODY$
  declare longprofstring text;
  rec record;

begin
for rec in SELECT distinct primaryprofession from name_basics
LOOP
	longprofstring = concat(longprofstring, rec.primaryprofession, ', ');
END LOOP; 
return query select * from string_to_table(longprofstring, ',');
end;
$BODY$
  LANGUAGE plpgsql VOLATILE


SELECT distinct * from profession_trim();

/*clears and prepares serial sequence for population*/
select currval(pg_get_serial_sequence('profession', 'profession_id')) as test_seq;
ALTER SEQUENCE test_seq RESTART WITH 0;

/*populates table profession*/
insert into profession(profession) 
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
  declare longprofstring text;
  rec record;
begin
drop table tempPrimProf; --if previous temptable exist, drop it 
Create temp table tempPrimProf(pid varchar, primprof text); -- create new temptable
for rec in SELECT nconst, primaryprofession from name_basics -- for loop with select statement
LOOP
insert into tempPrimProf(pid, primprof) values (rec.nconst, unnest(string_to_array(rec.primaryprofession, ',')));  --populat temp table (an intermidiary step for debugging purposes, should be replaced with population below)
END LOOP; 
insert into primary_profession(profession_id, person_id) select profession_id, pid from tempPrimProf tpp, profession p where p.profession = primprof; -- populate from temp table to profession
return query select * from tempPrimProf; -- for debugging purposes, can be removed as long as return type is changed too
end;
$$
