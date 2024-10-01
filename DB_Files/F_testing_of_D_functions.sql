-- d.1
-- change input id accordingly

-- rating

-- create customer rating
SELECT * from customer_rating;
call create_customer_rating(7, 'tt11510700', 8);
SELECT * from customer_rating;


-- get customer rating 
SELECT * from get_customer_rating(1, 'tt8392956');


-- get customer rating history
SELECT * from get_customer_rating_history(1);

-- update customer rating
SELECT * from get_customer_rating(1, 'tt8392956');
call update_customer_rating(1, 'tt8392956', 9);
SELECT * from get_customer_rating(1, 'tt8392956');
  
-- delete rating
SELECT * from customer_rating;
CALL delete_rating(1, 'tt10265158'); 
SELECT * from customer_rating;


 -- get customer search history
SELECT * from get_customer_search_history(1);