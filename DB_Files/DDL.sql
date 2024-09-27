DROP TABLE IF EXISTS TITLE CASCADE;

CREATE TABLE TITLE
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

DROP TABLE IF EXISTS PERSON CASCADE;
CREATE TABLE PERSON
(
person_ID varchar(10) primary key,
primary_name varchar(256),
birth_year numeric(4),
death_year numeric(4)
);

DROP TABLE IF EXISTS PROFESSION CASCADE;
CREATE TABLE PROFESSION
(
profession_ID serial NOT NULL UNIQUE, --Denne skal være NOT NULL UNIQUE, da vi i primaryproffession specificerer den som foreign key
profession varchar(256),
primary key (profession_ID, profession) 
);

DROP TABLE IF EXISTS PRIMARYPROFESSION CASCADE;
CREATE TABLE PRIMARYPROFESSION
(
profession_ID int4, -- Change after non-atomized column primaryProfession has been corrected
person_ID varchar(10),
primary key (profession_ID, person_ID), 
foreign key(profession_ID) references PROFESSION (profession_ID),
foreign key(person_ID) references PERSON (person_ID)
);

DROP TABLE IF EXISTS MostRelevant CASCADE;
CREATE TABLE MostRelevant
(
person_ID varchar(10),
title_ID varchar(10),
primary key (person_ID, title_ID),
foreign key (person_ID) references PERSON (person_ID),
foreign key(title_ID) references TITLE (title_ID) 
);

DROP TABLE IF EXISTS GenreList CASCADE;
CREATE TABLE GenreList
(
genre_ID serial primary key,
genre varchar(256)

);

DROP TABLE IF EXISTS TitleGenre CASCADE;
CREATE TABLE TitleGenre
(
title_ID varchar(10),
genre_ID SMALLINT,

primary key (title_ID, genre_ID),
foreign key (title_ID) references TITLE (title_ID),
foreign key (genre_ID) references GenreList(genre_ID)
);

DROP TABLE IF EXISTS PLOT CASCADE;
CREATE TABLE PLOT
(
title_ID varchar(10) primary key,
plot text,
foreign key (title_ID) references TITLE (title_ID)
);

DROP TABLE IF EXISTS POSTER CASCADE;
CREATE TABLE POSTER
(
title_ID varchar(10) primary key,
poster text,
foreign key (title_ID) references TITLE (title_ID)
);

DROP TABLE IF EXISTS EPISODEFROMSERIES CASCADE;
CREATE TABLE EPISODEFROMSERIES
(
title_ID varchar(10),
series_title_ID varchar(10),
season_num numeric(2),
episode_num numeric (4),

primary key (title_ID, series_title_ID),
foreign key (title_ID) references TITLE (title_ID),
foreign key (series_title_ID) references TITLE (title_ID)

);

DROP TABLE IF EXISTS LocalizedTitle CASCADE;
CREATE TABLE LocalizedTitle
(
localized_ID serial,
title_ID varchar(10),
primary key (localized_ID),
foreign key (title_ID) references TITLE (title_ID)

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

foreign key (localized_ID) references LocalizedTitle (localized_ID)

);

DROP TABLE IF EXISTS PrincipleCast CASCADE;
CREATE TABLE PrincipleCast 
(
person_ID varchar(10),
ordering numeric(2),
title_ID varchar(10),
character_name text,
category varchar(50),
job text,

primary key (person_ID, title_ID, ordering),
foreign key (title_ID) references TITLE (title_ID),
foreign key (person_ID) references PERSON (person_ID)

);

DROP TABLE IF EXISTS Rating CASCADE;
CREATE TABLE Rating
(
title_ID varchar(10) primary key,
average_rating numeric(3,1), ---Ændret denne til 3,1, da man ellers kun kan vise max 9.9
vote_count numeric(7),

foreign key (title_ID) references TITLE (title_ID)

);

DROP TABLE IF EXISTS WordIndex CASCADE;
CREATE TABLE WordIndex
(
title_ID varchar(10),
word text,
field char(1),
lexeme text,

primary key (title_ID, word),
foreign key (title_ID) references TITLE (title_ID)

);