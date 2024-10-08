DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer
(
customer_ID serial PRIMARY KEY,
email VARCHAR(256) NOT NULL UNIQUE,
firstname VARCHAR(50) NOT NULL UNIQUE,
password TEXT NOT NULL 
);

DROP TABLE IF EXISTS customer_search_history CASCADE;
CREATE TABLE customer_search_history
(
customer_ID INT4,
search_terms TEXT,
created_at TIMESTAMP,

PRIMARY KEY (customer_ID, created_at),
FOREIGN KEY (customer_ID) REFERENCES customer (customer_ID) on DELETE CASCADE

);

DROP TABLE IF EXISTS customer_rating CASCADE;
CREATE TABLE customer_rating
(
customer_ID INT4,
title_ID VARCHAR(10),
rating NUMERIC(3,1),
created_at TIMESTAMP,

PRIMARY KEY (customer_ID, title_ID),
FOREIGN KEY (customer_ID) REFERENCES customer (customer_ID) on DELETE CASCADE,
FOREIGN KEY (title_ID) REFERENCES TITLE (title_ID) on DELETE CASCADE

);

DROP TABLE IF EXISTS customer_title_bookmark CASCADE;
CREATE TABLE customer_title_bookmark
(
customer_ID INT4,
title_ID VARCHAR(10),
created_at TIMESTAMP,
annotation TEXT,

PRIMARY KEY (customer_ID, title_ID),
FOREIGN KEY (customer_ID) REFERENCES customer (customer_ID) on DELETE CASCADE,
FOREIGN KEY (title_ID) REFERENCES TITLE (title_ID) on DELETE CASCADE

);

DROP TABLE IF EXISTS customer_person_bookmark CASCADE;
CREATE TABLE customer_person_bookmark
(
customer_ID INT4,
person_ID varchar(10),
created_at TIMESTAMP,
annotation TEXT, --Hvilken datatype?? Text er fint

PRIMARY KEY (customer_ID, person_ID),
FOREIGN KEY (customer_ID) REFERENCES customer (customer_ID) on DELETE CASCADE,
FOREIGN KEY (person_ID) REFERENCES person (person_ID) on DELETE CASCADE

);


