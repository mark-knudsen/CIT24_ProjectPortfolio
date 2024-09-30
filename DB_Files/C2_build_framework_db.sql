
DROP TABLE IF EXISTS Member CASCADE;
CREATE TABLE Member
(
serial_ID serial PRIMARY KEY,
email VARCHAR(256) NOT NULL UNIQUE,
firstname VARCHAR(50) NOT NULL UNIQUE,
password TEXT NOT NULL 
);

DROP TABLE IF EXISTS Member_History CASCADE;
CREATE TABLE Member_History
(
serial_ID INT4 PRIMARY KEY,
search_terms SMALLINT,
created_at TIMESTAMP,

FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID)

);

DROP TABLE IF EXISTS Member_Rating CASCADE;
CREATE TABLE Member_Rating
(
serial_ID INT4,
title_ID VARCHAR(10),
rating NUMERIC(3,1),
created_at TIMESTAMP,

PRIMARY KEY (serial_ID, title_ID),
FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID),
FOREIGN KEY (title_ID) REFERENCES TITLE (title_ID)

);

DROP TABLE IF EXISTS Member_Title_Bookmark CASCADE;

CREATE TABLE Member_Title_Bookmark
(
serial_ID INT4,
title_ID VARCHAR(10),
created_at TIMESTAMP,
annotation TEXT,

PRIMARY KEY (serial_ID, title_ID, created_at),
FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID),
FOREIGN KEY (title_ID) REFERENCES TITLE (title_ID)

);

DROP TABLE IF EXISTS Member_Person_Bookmark CASCADE;
CREATE TABLE Member_Person_Bookmark
(
serial_ID INT4,
person_ID varchar(10),
created_at TIMESTAMP,
annotation TEXT, --Hvilken datatype??

PRIMARY KEY (serial_ID, person_ID, created_at),
FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID),
FOREIGN KEY (person_ID) REFERENCES person (person_ID)

);
