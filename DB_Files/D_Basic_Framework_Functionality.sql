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
return query select email, firstname from customer where email = arg_email;
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


/*Searches a string and saves the search result to an ID*/
CREATE OR REPLACE FUNCTION string_search(arg_customer_ID INT4, query TEXT)
RETURNS TABLE(title_id VARCHAR(10), primary_title TEXT)
    LANGUAGE plpgsql 
    as  $$
    
  BEGIN
  INSERT INTO customer_search_history(customer_id, search_terms, created_at) values(arg_customer_ID, query, NOW());
RETURN query (SELECT t.title_id, t.primary_title FROM title as t NATURAL JOIN plot as p WHERE position(query in t.primary_title)>0 OR position(query in p.plot)>0);
END;
$$;

/*insert a rating into table customer_rating*/
CREATE  PROCEDURE CreateCustomerRating(arg_customer_ID int4, arg_title_ID varchar, arg_rating numeric(3,1))
     LANGUAGE plpgsql 
		 as  $BODY$
begin

IF arg_rating > 10.0 OR arg_rating < 0 OR EXISTS(select customer_id, title_id from customer_rating where customer_id = arg_customer_id and title_id = arg_title_id) THEN
	raise exception 'Outside of rating range. min: 0.0 max: 10.0 AND/OR user already rated this movie';

ELSE
	insert into customer_rating(customer_id, title_id, rating, created_at) values (arg_customer_ID, arg_title_ID, arg_rating, now());

END IF;

end;
$BODY$

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
$$;


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
