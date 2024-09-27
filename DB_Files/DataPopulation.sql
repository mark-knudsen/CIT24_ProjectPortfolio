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
  profession_array text[];
begin
 
for rec in SELECT distinct primaryprofession from name_basics
LOOP
	longprofstring = concat(longprofstring, rec.primaryprofession, ', '); 
  --longprofstring
END LOOP;
 
profession_array = regexp_split_to_array(longprofstring, '^(.*?(\bpass\b)[^$]*)$');
raise notice '%', profession_array;
--return regexp_split_to_array((SELECT primaryprofession from name_basics WHERE nconst='nm0000001'), '^(.*?(\bpass\b)[^$]*)$');

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

