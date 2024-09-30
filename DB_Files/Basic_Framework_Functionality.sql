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
CREATE OR REPLACE FUNCTION string_search(arg_customer_ID INT4, arg_query TEXT)
RETURNS TABLE(title_id VARCHAR(10), primary_title TEXT)
    LANGUAGE plpgsql 
    as  $$
  BEGIN
  INSERT INTO customer_search_history(customer_id, search_terms, created_at) values(arg_customer_ID , arg_query, NOW());
RETURN query (SELECT t.title_id, t.primary_title FROM title as t NATURAL JOIN plot as p WHERE position(arg_query in t.primary_title)>0 OR position(arg_query in p.plot)>0);
END;
$$;