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


-- search
SELECT * from get_customer_search_history(7);
SELECT * from customer_search_history;


-- d2

-- d3

-- d4
SELECT * from structured_search_query(7, '','wizard','','');


-- d5
SELECT * from structured_actor_search_query(7, '','twilight','','');


-- d6
SELECT * from determine_coplayers('marlon');


-- d7
alter table person add column person_average_rating numeric(3,1);
SELECT * from person;

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

SELECT * from person;


SELECT * from person;

