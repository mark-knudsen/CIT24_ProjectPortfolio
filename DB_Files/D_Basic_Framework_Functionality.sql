/************************************************CUSTOMER************************************************/

/*Creates customer*/
CREATE OR REPLACE PROCEDURE create_customer(arg_email VARCHAR, arg_firstname VARCHAR, arg_password TEXT)
     LANGUAGE plpgsql AS  
$BODY$
  BEGIN
    INSERT INTO customer(email, firstname, PASSWORD) VALUES (arg_email, arg_firstname, arg_password);
  END;
$BODY$


/*Get Customer*/
CREATE OR REPLACE FUNCTION get_customer(arg_email VARCHAR)
RETURNS TABLE (email VARCHAR, firstname VARCHAR) 
LANGUAGE plpgsql AS  
$BODY$
  BEGIN
    RETURN query SELECT customer.email, customer.firstname FROM customer WHERE customer.email = arg_email;
  END;
$BODY$



/*Delete customer*/
CREATE OR REPLACE PROCEDURE delete_customer(arg_email VARCHAR)
  LANGUAGE plpgsql AS 
$BODY$
  BEGIN
    DELETE FROM customer
    WHERE email = arg_email;
    -- improvements include to inform if any customer was deleted.
  END;
$BODY$




/************************************************RATING************************************************/




-- create customer rating
CREATE OR REPLACE PROCEDURE create_customer_rating(arg_customer_ID int4, arg_title_ID VARCHAR, arg_rating NUMERIC(3,1))
LANGUAGE plpgsql AS  
$BODY$
    BEGIN
    IF arg_rating > 10.0 OR arg_rating < 0 OR EXISTS(select customer_id, title_id FROM customer_rating WHERE customer_id = arg_customer_id AND title_id = arg_title_id) THEN

	    raise EXCEPTION 'Outside of rating range. min: 0.0 max: 10.0 AND/OR this customer has already rated this movie';
    ELSE
	    INSERT INTO customer_rating(customer_id, title_id, rating, created_at) VALUES (arg_customer_ID, arg_title_ID, arg_rating, now());

    END IF;

    END;
$BODY$


-- get customer rating 
CREATE OR REPLACE FUNCTION get_customer_rating(arg_customer_ID int4, arg_title_ID VARCHAR)
  RETURNS TABLE("customer_ID" int4, "title_ID" VARCHAR, "rating" NUMERIC(3,1), "created_at" TIMESTAMP) AS $BODY$
  BEGIN
    RETURN query SELECT * FROM customer_rating WHERE customer_ID = arg_customer_ID AND title_ID=arg_title_ID;

  END;
$BODY$
  LANGUAGE plpgsql VOLATILE 
  
  
-- get customer rating history
CREATE OR REPLACE FUNCTION get_customer_rating_history(arg_customer_ID int4)
  RETURNS TABLE("customer_ID" int4, "title_ID" VARCHAR, "rating" NUMERIC(3,1), "created_at" TIMESTAMP) AS $BODY$
  BEGIN
    RETURN query SELECT * FROM customer_rating WHERE customer_ID=arg_customer_ID ORDER BY created_at;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE 
  
  
-- delete rating
CREATE OR REPLACE PROCEDURE delete_rating(arg_customer_ID int4, arg_title_ID VARCHAR)
   LANGUAGE plpgsql AS  
$BODY$
  BEGIN

   IF EXISTS (SELECT 1 FROM customer_rating WHERE customer_IDd=arg_customer_ID AND title_ID=arg_title_ID) THEN
          DELETE FROM customer_rating WHERE customer_ID=arg_customer_ID AND title_ID=arg_title_ID;
          RAISE NOTICE 'rating deleted successfully.';
      ELSE
          RAISE EXCEPTION 'rating with customer_ID % does not exist.', arg_customer_ID;
      END IF;

  --DELETE from rating WHERE customer_ID=arg_ and title_ID=arg_title_ID;
  END;
$BODY$


/*update rating made previously for the same customer/title */
CREATE OR REPLACE PROCEDURE update_customer_rating(arg_customer_ID int4, arg_title_ID VARCHAR, arg_rating NUMERIC(3,1))
     LANGUAGE plpgsql AS  
$BODY$
  BEGIN

  if EXISTS(select customer_id, title_id FROM customer_rating WHERE customer_id = arg_customer_id AND title_id = arg_title_id AND arg_rating != rating) THEN
    update customer_rating SET rating = arg_rating, created_at = now() WHERE customer_id = arg_customer_id AND title_id = arg_title_id;
    ELSE
    raise EXCEPTION 'No previous rating for title was found';
  END IF;

  END;
$BODY$



/************************************************BOOKMARKS************************************************/

/* Create Bookmark for title. */
CREATE OR REPLACE PROCEDURE create_title_bookmark(
  IN customer_ID INT, 
  IN title_ID VARCHAR, 
  IN annotation TEXT DEFAULT NULL
) LANGUAGE plpgsql AS 
$$
  BEGIN
    INSERT INTO customer_title_bookmark(customer_ID, title_ID, created_at, annotation)
    VALUES (customer_id, title_id, NOW(), annotation);    
  END;
$$



/* Create Bookmark for person. */
CREATE OR REPLACE PROCEDURE create_person_bookmark(
  IN customer_ID INT, 
  IN person_ID VARCHAR, 
  IN annotation TEXT DEFAULT NULL
) LANGUAGE plpgsql AS 
$$
  BEGIN
    INSERT INTO customer_person_bookmark(customer_ID, person_ID, created_at, annotation)
    VALUES (customer_id, person_id, NOW(), annotation);    
  END;
$$;


/* Get  title bookmark */
CREATE OR REPLACE FUNCTION get_title_bookmark (cust_id INT, tit_id VARCHAR)
RETURNS TABLE(customer_id INT, title_id VARCHAR, created_at TIMESTAMP, notation TEXT)
LANGUAGE plpgsql AS $$
    BEGIN
      RETURN query
      SELECT *
      FROM customer_title_bookmark AS CTB
      WHERE CTB.customer_id = cust_id AND CTB.title_id = tit_id;
  END;
$$;

/* Get person bookmark */
CREATE OR REPLACE FUNCTION get_person_bookmark (cust_id INT, per_id VARCHAR)
  RETURNS TABLE(customer_id INT, person_id VARCHAR, created_at TIMESTAMP, notation TEXT)
LANGUAGE plpgsql AS 
$$
  BEGIN
    RETURN query
    SELECT *
    FROM customer_person_bookmark AS CTB
    WHERE CTB.customer_id = cust_id AND CTB.person_id = per_id;
  END;
$$;


/*delete title bookmarks*/
CREATE OR REPLACE PROCEDURE delete_title_bookmark(arg_customer_ID int, arg_title_ID VARCHAR)
  LANGUAGE plpgsql AS  
$BODY$
  BEGIN
    DELETE FROM customer_title_bookmark
    WHERE customer_id= arg_customer_ID AND title_id = title_ID;
  END;
$BODY$


/*delete person bookmarks*/
CREATE OR REPLACE PROCEDURE delete_person_bookmark(arg_customer_ID int, arg_person_ID VARCHAR)
  LANGUAGE plpgsql AS
$BODY$
  BEGIN
    DELETE FROM customer_person_bookmark
    WHERE customer_id= arg_customer_ID AND person_id = person_ID;
  END;
$BODY$



/************************************************Search************************************************************/

/*Searches a string and saves the search result to an ID*/
CREATE OR REPLACE FUNCTION string_search(arg_customer_ID int4, query TEXT)
RETURNS TABLE(title_id VARCHAR(10), primary_title TEXT)
    LANGUAGE plpgsql AS 
$$    
  BEGIN
    INSERT INTO customer_search_history(customer_id, search_terms, created_at) values(arg_customer_ID, query, NOW());
    RETURN query (SELECT t.title_id, t.primary_title FROM title as t NATURAL JOIN plot as p WHERE position(query in t.primary_title)>0 OR position(query in p.plot)>0);
  END;
$$;

 -- get customer search history
CREATE OR REPLACE FUNCTION get_customer_search_history(arg_customer_ID int4)
  RETURNS TABLE("customer_ID" int4, "search_terms" TEXT, "created_at" TIMESTAMP) AS 
$BODY$
  BEGIN
    RETURN query SELECT * FROM customer_search_history WHERE customer_ID=arg_customer_ID ORDER BY created_at;
  --raise exception 'big error, beware';
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE 
   
  
-- create customer search history
CREATE OR REPLACE PROCEDURE create_customer_search_history(arg_customer_ID int4, arg_search_terms TEXT)
  LANGUAGE plpgsql AS  
$BODY$
  BEGIN
    INSERT into customer_search_history VALUES(arg_costumer_ID, arg_search_terms, CURRENT_TIMESTAMP);
  END;
$BODY$



/***************************************Rating trigger***************************************/


/* Function to Update average_rating from Rating when inserting a customer_rating */
CREATE OR REPLACE FUNCTION trigger_update_rating()
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
FOR EACH ROW EXECUTE FUNCTION trigger_update_rating();




/* Function to Update average_rating from rating when deleting a customer_rating */
CREATE OR REPLACE FUNCTION trigger_delete_rating()
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
FOR EACH ROW EXECUTE FUNCTION trigger_delete_rating();

