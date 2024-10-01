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


CREATE OR REPLACE PROCEDURE CreateCustomerRating(arg_customer_ID int4, arg_title_ID varchar, arg_rating numeric(3,1))
LANGUAGE plpgsql as  
$BODY$
    begin
    IF arg_rating > 10.0 OR arg_rating < 0 OR EXISTS(select customer_id, title_id from customer_rating where customer_id = arg_customer_id and title_id = arg_title_id) THEN

	    raise notice 'Outside of rating range. min: 0.0 max: 10.0 AND/OR this customer has already rated this movie';
    ELSE
	    insert into customer_rating(customer_id, title_id, rating, created_at) values (arg_customer_ID, arg_title_ID, arg_rating, now());

    END IF;

    end;
$BODY$



-- get customer rating 

CREATE OR REPLACE FUNCTION GetCustomerRating(arg_customer_ID int4, arg_title_ID VARCHAR)
  RETURNS TABLE("costumer_ID" int4, "title_ID" varchar, "rating" numeric(3,1), "created_at" TIMESTAMP) AS $BODY$
begin
return query SELECT * from customer_rating WHERE customer_ID = arg_customer_ID and title_ID=arg_title_ID;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE 

  
-- delete rating

CREATE OR REPLACE PROCEDURE DeleteRating(arg_customer_ID int4, arg_title_ID varchar)
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
CREATE  PROCEDURE UpdateCustomerRating(arg_customer_ID int4, arg_title_ID varchar, arg_rating numeric(3,1))
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



