/*Creates customer*/
CREATE  PROCEDURE CreateCustomer(email VARCHAR, firstname VARCHAR, password text)
     LANGUAGE plpgsql 
		 as  $BODY$
begin
insert into customer(email, firstname, PASSWORD) values (email, firstname, password);
end;
$BODY$

/*Get Customer*/
create or replace function GetCustomer(input_email varchar)
returns  table (output_email varchar, output_firstname varchar) 
LANGUAGE plpgsql 
as  $BODY$
BEGIN
return query select email, firstname from customer where email = input_email;
end;
$BODY$

/*Delete customer*/
create procedure DeleteCustomer(input_email varchar)
  LANGUAGE plpgsql 
		 as  $BODY$
begin
DELETE FROM customer
WHERE email = input_email;
-- improvements include to inform if any customer was deleted.
end;
$BODY$

/*Searches a string and saves the search result to an ID*/
CREATE OR REPLACE FUNCTION string_search(cID INT4, query TEXT)
RETURNS TABLE(title_id VARCHAR(10), primary_title TEXT)
    LANGUAGE plpgsql 
    as  $$
  BEGIN
  INSERT INTO customer_search_history(customer_id, search_terms, created_at) values(cID, query, NOW());
RETURN query (SELECT t.title_id, t.primary_title FROM title as t NATURAL JOIN plot as p WHERE position(query in t.primary_title)>0 OR position(query in p.plot)>0);
END;
$$;
