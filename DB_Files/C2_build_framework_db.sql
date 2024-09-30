
DROP TABLE IF EXISTS Member CASCADE;
CREATE TABLE Member
(
serial_ID serial PRIMARY KEY,
email VARCHAR(256) NOT NULL UNIQUE,
firstname VARCHAR(50) NOT NULL UNIQUE,
password TEXT NOT NULL 
);

DROP TABLE IF EXISTS MemberHistory CASCADE;
CREATE TABLE MemberHistory
(
serial_ID INT4 PRIMARY KEY,
search_terms SMALLINT,
created_at TIMESTAMP,

FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID)
);

DROP TABLE IF EXISTS MemberRating CASCADE;
CREATE TABLE MemberRating
(
serial_ID INT4,
title_ID VARCHAR(10),
rating NUMERIC(3,1),
created_at TIMESTAMP,

PRIMARY KEY (serial_ID, title_ID),
FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID),
FOREIGN KEY (title_ID) REFERENCES TITLE (title_ID)
);

DROP TABLE IF EXISTS MemberTitleBookmark CASCADE;

CREATE TABLE MemberTitleBookmark
(
serial_ID INT4,
title_ID VARCHAR(10),
created_at TIMESTAMP,
annotation TEXT,

PRIMARY KEY (serial_ID, title_ID, created_at),
FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID),
FOREIGN KEY (title_ID) REFERENCES TITLE (title_ID)
);

DROP TABLE IF EXISTS MemberPersonBookmark CASCADE;
CREATE TABLE MemberPersonBookmark
(
serial_ID INT4,
person_ID varchar(10),
created_at TIMESTAMP,
annotation TEXT, --Hvilken datatype??

PRIMARY KEY (serial_ID, person_ID, created_at),
FOREIGN KEY (serial_ID) REFERENCES Member (serial_ID),
FOREIGN KEY (person_ID) REFERENCES person (person_ID)
);
