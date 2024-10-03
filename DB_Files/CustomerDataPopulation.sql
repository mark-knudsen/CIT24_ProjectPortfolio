-- insert dummy data for our customer framework
-- remember to change the customer_ID accordingly on insert

-- create trigger function that sets created_at attribute to current time
CREATE OR REPLACE FUNCTION set_created_at() 
RETURNS "pg_catalog"."trigger" AS 
$BODY$
  BEGIN
    new.created_at=CURRENT_TIMESTAMP;
    RETURN new;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

  

-- create customer table
DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer
(
customer_ID serial PRIMARY KEY,
email VARCHAR(256) NOT NULL UNIQUE,
firstname VARCHAR(50) NOT NULL UNIQUE,
password TEXT NOT NULL 
);

-- create customer search history table
DROP TABLE IF EXISTS customer_search_history CASCADE;
CREATE TABLE customer_search_history
(
customer_ID INT4,
search_terms TEXT,
created_at TIMESTAMP,

PRIMARY KEY (customer_ID, created_at),
FOREIGN KEY (customer_ID) REFERENCES customer (customer_ID) on DELETE CASCADE

);

-- create ustomer search history insert trigger 
CREATE TRIGGER customer_search_history_insert_trigger 
BEFORE INSERT on customer_search_history
FOR EACH ROW EXECUTE PROCEDURE set_created_at();

-- insert into customer
INSERT INTO customer (email, firstname, password) VALUES
('john.doe@example.com', 'John', 'password123'),
('jane.smith@example.com', 'Jane', 'securepassword'),
('michael.johnson@example.com', 'Michael', 'mystrongpassword');



-- insert into customer search history
INSERT INTO customer_search_history (customer_ID, search_terms) VALUES (1, 'star wars');
INSERT INTO customer_search_history (customer_ID, search_terms) VALUES (2, 'science fiction books');
INSERT INTO customer_search_history (customer_ID, search_terms) VALUES (1, 'fantasy novels');


-- create customer rating table
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

-- create customer rating insert trigger 
CREATE TRIGGER customer_rating_insert_trigger 
BEFORE INSERT on customer_rating
FOR EACH ROW EXECUTE PROCEDURE set_created_at(); 

-- insert into customer rating
INSERT INTO customer_rating (customer_ID, title_ID, rating) VALUES
(1, 'tt8392956', 4.5),
(2, 'tt10265158', 3.0),
(1, 'tt20541384', 5.0);



-- create customer title bookmark table
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

-- create customer title bookmark insert trigger
CREATE TRIGGER customer_title_bookmark_insert_trigger 
BEFORE INSERT on customer_title_bookmark
FOR EACH ROW EXECUTE PROCEDURE set_created_at(); 

-- insert into customer title bookmark
INSERT INTO customer_title_bookmark (customer_ID, title_ID, annotation) VALUES (1, 'tt11632488', 'Really enjoyed this book!');
INSERT INTO customer_title_bookmark (customer_ID, title_ID, annotation) VALUES (2, 'tt10265158', 'Interesting plot, could be been better');
INSERT INTO customer_title_bookmark (customer_ID, title_ID, annotation) VALUES (1, 'tt20541384', 'My favorite book of all time!');



-- create customer person bookmark
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

-- create customer person bookmark trigger
CREATE TRIGGER customer_person_bookmark_insert_trigger 
BEFORE INSERT on customer_person_bookmark
FOR EACH ROW EXECUTE PROCEDURE set_created_at(); 


-- insert into customer person bookmark
INSERT INTO customer_person_bookmark (customer_ID, person_ID, annotation) VALUES (1, 'nm0003578', 'Great author');
INSERT INTO customer_person_bookmark (customer_ID, person_ID, annotation) VALUES (2, 'nm0003577', 'Interesting perspective');
INSERT INTO customer_person_bookmark (customer_ID, person_ID, annotation) VALUES (1, 'nm0003648', 'My favorite character');
