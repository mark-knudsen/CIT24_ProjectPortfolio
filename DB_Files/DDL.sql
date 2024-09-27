DROP TABLE IF EXISTS title CASCADE;

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

DROP TABLE IF EXISTS person CASCADE;
CREATE TABLE person
(
person_ID varchar(10) primary key,
primary_name varchar(256),
birth_year numeric(4),
death_year numeric(4)
);

DROP TABLE IF EXISTS profession CASCADE;
CREATE TABLE profession
(
profession_ID serial NOT NULL UNIQUE, --Denne skal være NOT NULL UNIQUE, da vi i primaryproffession specificerer den som foreign key
profession varchar(256),
primary key (profession_ID, profession) 
);

DROP TABLE IF EXISTS PRIMARYprofession CASCADE;
CREATE TABLE PRIMARYprofession
(
profession_ID int4, -- Change after non-atomized column primaryProfession has been corrected
person_ID varchar(10),
primary key (profession_ID, person_ID), 
foreign key(profession_ID) references profession (profession_ID),
foreign key(person_ID) references person (person_ID)
);

DROP TABLE IF EXISTS MostRelevant CASCADE;
CREATE TABLE MostRelevant
(
person_ID varchar(10),
title_ID varchar(10),
primary key (person_ID, title_ID),
foreign key (person_ID) references person (person_ID),
foreign key(title_ID) references title (title_ID) 
);

DROP TABLE IF EXISTS genre_list CASCADE;
CREATE TABLE genre_list
(
genre_ID serial primary key,
genre varchar(256)

);

DROP TABLE IF EXISTS title_genre CASCADE;
CREATE TABLE title_genre
(
title_ID varchar(10),
genre_ID SMALLINT,

primary key (title_ID, genre_ID),
foreign key (title_ID) references title (title_ID),
foreign key (genre_ID) references genre_list(genre_ID)
);

DROP TABLE IF EXISTS plot CASCADE;
CREATE TABLE plot
(
title_ID varchar(10) primary key,
plot text,
foreign key (title_ID) references title (title_ID)
);

DROP TABLE IF EXISTS poster CASCADE;
CREATE TABLE poster
(
title_ID varchar(10) primary key,
poster text,
foreign key (title_ID) references title (title_ID)
);

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

DROP TABLE IF EXISTS localized_title CASCADE;
CREATE TABLE localized_title
(
localized_ID serial,
title_ID varchar(10),
primary key (localized_ID),
foreign key (title_ID) references title (title_ID)

);

DROP TABLE IF EXISTS LocalizedDetail CASCADE;
CREATE TABLE LocalizedDetail
(
localized_ID INT4 primary key,
localized_title text,
language varchar(10),
region varchar(10),
type varchar(256),
attribute varchar(256),

foreign key (localized_ID) references localized_title (localized_ID)

);

DROP TABLE IF EXISTS principle_cast CASCADE;
CREATE TABLE principle_cast 
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

DROP TABLE IF EXISTS rating CASCADE;
CREATE TABLE rating
(
title_ID varchar(10) primary key,
average_rating numeric(3,1), ---Ændret denne til 3,1, da man ellers kun kan vise max 9.9
vote_count numeric(7),

foreign key (title_ID) references title (title_ID)

);

DROP TABLE IF EXISTS word_index CASCADE;
CREATE TABLE word_index
(
title_ID varchar(10),
word text,
field char(1),
lexeme text,

primary key (title_ID, word),
foreign key (title_ID) references title (title_ID)

);