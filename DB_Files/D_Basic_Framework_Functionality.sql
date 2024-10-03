/************************************************CUSTOMER************************************************/

/*Creates customer*/
CREATE  PROCEDURE CreateCustomer(arg_email VARCHAR, arg_firstname VARCHAR, arg_password text)
     LANGUAGE plpgsql 
		 as  $BODY$
begin
insert into customer(email, firstname, PASSWORD) values (arg_email, arg_firstname, arg_password);
end;
$BODY$

/*Get Customer*/
create or replace function GetCustomer(arg_email varchar)
returns  table (email varchar, firstname varchar) 
LANGUAGE plpgsql 
as  $BODY$
BEGIN
return query select customer.email, customer.firstname from customer where customer.email = arg_email;
end;
$BODY$


/*Delete customer*/
create procedure DeleteCustomer(arg_email varchar)
  LANGUAGE plpgsql 
		 as  $BODY$
begin
DELETE FROM customer
WHERE email = arg_email;
-- improvements include to inform if any customer was deleted.
end;
$BODY$




/************************************************RATING************************************************/




-- create customer rating

CREATE OR REPLACE PROCEDURE create_customer_rating(arg_customer_ID int4, arg_title_ID varchar, arg_rating numeric(3,1))
LANGUAGE plpgsql as  
$BODY$
    begin
    IF arg_rating > 10.0 OR arg_rating < 0 OR EXISTS(select customer_id, title_id from customer_rating where customer_id = arg_customer_id and title_id = arg_title_id) THEN

	    raise exception 'Outside of rating range. min: 0.0 max: 10.0 AND/OR this customer has already rated this movie';
    ELSE
	    insert into customer_rating(customer_id, title_id, rating, created_at) values (arg_customer_ID, arg_title_ID, arg_rating, now());

    END IF;

    end;
$BODY$


-- get customer rating 

CREATE OR REPLACE FUNCTION get_customer_rating(arg_customer_ID int4, arg_title_ID VARCHAR)
  RETURNS TABLE("customer_ID" int4, "title_ID" varchar, "rating" numeric(3,1), "created_at" TIMESTAMP) AS $BODY$
begin
return query SELECT * from customer_rating WHERE customer_ID = arg_customer_ID and title_ID=arg_title_ID;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE 
  
  
-- get customer rating history

CREATE OR REPLACE FUNCTION get_customer_rating_history(arg_customer_ID int4)
  RETURNS TABLE("customer_ID" int4, "title_ID" varchar, "rating" numeric(3,1), "created_at" TIMESTAMP) AS $BODY$
begin
return query SELECT * from customer_rating WHERE customer_ID=arg_customer_ID ORDER BY created_at;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE 
  
  
-- delete rating

CREATE OR REPLACE PROCEDURE delete_rating(arg_customer_ID int4, arg_title_ID varchar)
   LANGUAGE plpgsql as  
$BODY$
begin

 IF EXISTS (SELECT 1 from customer_rating WHERE customer_IDd=arg_customer_ID and title_ID=arg_title_ID) THEN
        DELETE from customer_rating WHERE customer_ID=arg_customer_ID and title_ID=arg_title_ID;
        RAISE NOTICE 'rating deleted successfully.';
    ELSE
        RAISE EXCEPTION 'rating with customer_ID % does not exist.', arg_customer_ID;
    END IF;

--DELETE from rating WHERE customer_ID=arg_ and title_ID=arg_title_ID;
end;
$BODY$


/*update rating made previously for the same customer/title */
CREATE  PROCEDURE update_customer_rating(arg_customer_ID int4, arg_title_ID varchar, arg_rating numeric(3,1))
     LANGUAGE plpgsql 
		 as  $BODY$
begin

if EXISTS(select customer_id, title_id from customer_rating where customer_id = arg_customer_id and title_id = arg_title_id AND arg_rating != rating) THEN
	update customer_rating set rating = arg_rating, created_at = now() where customer_id = arg_customer_id and title_id = arg_title_id;
	ELSE
	raise exception 'No previous rating for title was found';
END IF;

end;
$BODY$



/************************************************BOOKMARKS************************************************/

/* Create Bookmark for title. */
CREATE OR REPLACE PROCEDURE CreateTitleBookmark(
  in customer_ID INT, 
  in title_ID VARCHAR, 
  in annotation TEXT DEFAULT NULL
) LANGUAGE plpgsql AS 
$$
  BEGIN
    INSERT INTO customer_title_bookmark(customer_ID, title_ID, created_at, annotation)
    VALUES (customer_id, title_id, NOW(), annotation);    
  END;
$$



/* Create Bookmark for person. */
CREATE OR REPLACE PROCEDURE CreatePersonBookmark(
  in customer_ID INT, 
  in person_ID VARCHAR, 
  in annotation TEXT DEFAULT NULL
) LANGUAGE plpgsql AS 
$$
  BEGIN
    INSERT INTO customer_person_bookmark(customer_ID, person_ID, created_at, annotation)
    VALUES (customer_id, person_id, NOW(), annotation);    
  END;
$$;


/* Get  title bookmark */
CREATE OR REPLACE FUNCTION GetTitleBookmark (cust_id INT, tit_id VARCHAR)
RETURNS TABLE(customer_id INT, title_id VARCHAR, created_at TIMESTAMP, notation text)
LANGUAGE plpgsql AS $$
    BEGIN
      RETURN query
      SELECT *
      FROM customer_title_bookmark AS CTB
      WHERE CTB.customer_id = cust_id AND CTB.title_id = tit_id;
  END;
$$;

/* Get person bookmark */
CREATE OR REPLACE FUNCTION GetPersonBookmark (cust_id INT, per_id VARCHAR)
  RETURNS TABLE(customer_id INT, person_id VARCHAR, created_at TIMESTAMP, notation text)
LANGUAGE plpgsql AS 
$$
  BEGIN
    RETURN query
    SELECT *
    FROM customer_person_bookmark AS CTB
    WHERE CTB.customer_id = cust_id AND CTB.person_id = per_id;
  END;
$$;


/*delete  titlebookmarks*/
create procedure DeleteTitleBookmark(arg_customer_ID int, arg_title_ID varchar)
  LANGUAGE plpgsql 
		 as  $BODY$
begin
DELETE FROM customer_title_bookmark
WHERE customer_id= arg_customer_ID and title_id = title_ID;
end;
$BODY$


/*delete  personbookmarks*/
create procedure DeletePersonBookmark(arg_customer_ID int, arg_person_ID varchar)
  LANGUAGE plpgsql 
		 as  $BODY$
begin
DELETE FROM customer_person_bookmark
WHERE customer_id= arg_customer_ID and person_id = person_ID;
end;
$BODY$



/************************************************Search************************************************************/

/*Searches a string and saves the search result to an ID*/
CREATE OR REPLACE FUNCTION string_search(arg_customer_ID INT4, query TEXT)
RETURNS TABLE(title_id VARCHAR(10), primary_title TEXT)
    LANGUAGE plpgsql AS 
$$    
  BEGIN
  INSERT INTO customer_search_history(customer_id, search_terms, created_at) values(arg_customer_ID, query, NOW());
RETURN query (SELECT t.title_id, t.primary_title FROM title as t NATURAL JOIN plot as p WHERE position(query in t.primary_title)>0 OR position(query in p.plot)>0);
END;
$$;

 -- get customer search history
CREATE OR REPLACE FUNCTION GetCustomerSearchHistory(arg_customer_ID int4)
  RETURNS TABLE("customer_ID" int4, "search_terms" TEXT, "created_at" TIMESTAMP) AS $BODY$
BEGIN
RETURN query SELECT * FROM customer_search_history WHERE customer_ID=arg_customer_ID ORDER BY created_at;
--raise exception 'big error, beware';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE 
   
  
-- create customer search history
CREATE PROCEDURE CreateCustomerSearchHistory(arg_customer_ID int4, arg_search_terms text)
  LANGUAGE plpgsql AS  
$BODY$
  BEGIN
    INSERT into customer_search_history VALUES(arg_costumer_ID, arg_search_terms, CURRENT_TIMESTAMP);
  END;
$BODY$



-- create structured search query
drop function structured_search_query(int4, text, text, text, text);
CREATE OR REPLACE FUNCTION structured_search_query(arg_user_id int4, arg_title_name text=NULL::text, arg_plot text=NULL::text, arg_character text=NULL::text, arg_person_name text=NULL::text)
  RETURNS TABLE(title_id varchar, primary_name text) AS $BODY$

declare search_term text = arg_title_name || ',' || arg_plot || ',' || arg_character || ',' || arg_person_name;

begin 

if arg_title_name = '' and arg_plot = '' and arg_character = '' and arg_person_name = '' then
raise exception 'fill out the search tearm';
end if;

insert into customer_search_history values(arg_user_ID, search_term);

return query Select distinct title.title_id, title.primary_title from title NATURAL join plot NATURAL join principal_cast NATURAL join person WHERE
 primary_title ilike '%'|| arg_title_name || '%' and plot.plot ilike '%' || arg_plot || '%' and principal_cast.character_name ilike '%' || arg_character || '%'
and person.primary_name ilike '%' || arg_person_name || '%' and (principal_cast.category = 'actor' or principal_cast.category = 'actress');

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  

-- create structured actor search query
CREATE OR REPLACE FUNCTION structured_actor_search_query(arg_user_id int4, arg_title_name text=NULL::text, arg_plot text=NULL::text, arg_character text=NULL::text, arg_person_name text=NULL::text)
  RETURNS TABLE(primary_name varchar, actor_character text) AS $BODY$

declare search_term text = arg_title_name || ',' || arg_plot || ',' || arg_character || ',' || arg_person_name;

begin 

if arg_title_name = '' and arg_plot = '' and arg_character = '' and arg_person_name = '' then
raise exception 'fill out the search tearm';
end if;

insert into customer_search_history values(arg_user_ID, search_term);

return query Select distinct person.primary_name, principal_cast.character_name from title NATURAL join plot NATURAL join principal_cast NATURAL join person WHERE
 primary_title ilike '%'|| arg_title_name || '%' and plot.plot ilike '%' || arg_plot || '%' and principal_cast.character_name ilike '%' || arg_character || '%'
and person.primary_name ilike '%' || arg_person_name || '%' and (principal_cast.category = 'actor' or principal_cast.category = 'actress');

end;
$BODY$
  LANGUAGE plpgsql VOLATILE



/***************************************Rating trigger***************************************/


/* Function to Update average_rating from Rating when inserting a customer_rating */
CREATE OR REPLACE FUNCTION trigger_Update_Rating()
RETURNS TRIGGER LANGUAGE PLPGSQL AS
$$
  BEGIN
     UPDATE rating
     SET average_rating = 
        ((rating.average_rating * rating.vote_count) + NEW.rating) / (rating.vote_count + 1),
        vote_count = (rating.vote_count + 1)
     WHERE rating.title_id = NEW.title_id;

     RETURN NEW;
  END;
$$;

/* Insert customer rating trigger */
CREATE OR REPLACE TRIGGER after_insert_customer_rating_trigger
AFTER INSERT ON customer_rating
FOR EACH ROW EXECUTE FUNCTION trigger_Update_Rating();




/* Function to Update average_rating from rating when deleting a customer_rating */
CREATE OR REPLACE FUNCTION trigger_Delete_Rating()
RETURNS TRIGGER LANGUAGE PLPGSQL AS
$$
  BEGIN
    UPDATE rating
    SET 
        average_rating = 
        ((rating.average_rating * rating.vote_count) - OLD.rating) / (rating.vote_count - 1),
        vote_count = rating.vote_count - 1
    WHERE rating.title_id = OLD.title_id;

    RETURN OLD;
  END;
$$;

/* Delete customer rating trigger */
CREATE OR REPLACE TRIGGER after_delete_customer_rating_trigger
AFTER DELETE ON customer_rating
FOR EACH ROW EXECUTE FUNCTION trigger_Delete_Rating();


/* Function to determine coplayers */
CREATE OR REPLACE FUNCTION determine_coplayers(arg_actor_name text)
RETURNS TABLE (searched_coplayer_ID VARCHAR, searched_coplayer_name VARCHAR, coplayer_ID VARCHAR, coplayer_name VARCHAR, frequency BIGINT)
LANGUAGE plpgsql AS
$$
  BEGIN 
    RETURN query 
    SELECT 
      t1.person_id, 
      t1.primary_name, 
      t2.person_id, 
      t2.primary_name, 
      count(t2.title_ID) 
    FROM related_title_actors AS t1, related_title_actors AS t2 
    WHERE 
      t1.primary_name ilike '%' || arg_actor_name  || '%' 
      AND t2.title_ID=t1.title_ID 
      AND t1.person_id != t2.person_id
    GROUP BY 
    t1.person_id, 
    t1.primary_name, 
    t2.person_id, 
    t2.primary_name;
  END;
$$;


/* Material view for related actors */
DROP MATERIALIZED view related_title_actors;
CREATE OR REPLACE MATERIALIZED VIEW related_title_actors AS 
SELECT 
  distinct person_id, 
  primary_name,
  primary_title,
  title_ID
FROM 
  title NATURAL join principal_cast NATURAL join person
WHERE 
  principal_cast.category = 'actor' OR principal_cast.category = 'actress' 
ORDER BY person_id;



-- added average rating to person
alter table person add column person_average_rating numeric(3,1)

--Alter table person add column person_average_rating numeric(3,1)
DO $$ declare rec record;
begin
for rec in select * from related_title_actors natural join rating where related_title_actors.title_id = rating.title_id
loop

--raise notice '%', trunc((rec.vote_count*rec.average_rating)/(rec.vote_count),1);
update person
SET person_average_rating = trunc((rec.vote_count*rec.average_rating)/(rec.vote_count),1) where person_id = rec.person_id;
end loop;
end;
$$



/* Function to determine popular actors */
CREATE OR REPLACE FUNCTION popular_actors(arg_movie_title TEXT)

RETURNS TABLE (person_id VARCHAR, primary_name VARCHAR, person_average_rating NUMERIC)
LANGUAGE plpgsql AS
$$
  BEGIN 
    RETURN query SELECT rta.person_id, rta.primary_name, p.person_average_rating FROM related_title_actors as rta NATURAL JOIN person as p  WHERE primary_title ilike '%' || arg_movie_title || '%' ORDER BY person_average_rating DESC;
    
  END;
$$;

--Test of function popular_actors
SELECT * FROM popular_actors('Dinsdale!');

/* Function to determine popular coplayers */
CREATE OR REPLACE FUNCTION determine_popular_coplayers(arg_actor_name text)
RETURNS TABLE (coplayer_ID VARCHAR, coplayer_name VARCHAR, rating NUMERIC)
LANGUAGE plpgsql AS
$$
  BEGIN 
    RETURN query 
    SELECT
      t2.person_id, 
      t2.primary_name,
      p.person_average_rating
    FROM related_title_actors AS t1, related_title_actors AS t2 NATURAL JOIN person as p
    WHERE 
      t1.primary_name ilike '%' || arg_actor_name  || '%' 
      AND t2.title_ID=t1.title_ID 
      AND t1.person_id != t2.person_id
    ORDER BY
    p.person_average_rating DESC;
  END;
$$;

--Test of function determine_popular_coplayers
SELECT * from determine_popular_coplayers('Masaharu Fukuyama');
SELECT * FROM person WHERE person_id = 'nm1157364'

