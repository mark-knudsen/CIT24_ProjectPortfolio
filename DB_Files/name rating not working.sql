/* TASK: Derive a rating of names (just actors or all names, as you prefer) based on
ratings of the titles they are related to. Modify the database to store also these name ratings.
Make sure to give higher influence to titles with more votes in the calculation. You can do
this by Calculating a weighted average of the averagerating for the titles, where the
numvotes is used as weight.*/

Alter table person add column person_average_rating numeric(3,1)


DO $$ declare rec record; declare tempval numeric;
begin
drop table if exists tt;
create temp table tt (pid varchar, person_rating numeric (3,1));
for rec in select * from related_title_actors natural join rating where related_title_actors.
title_id = rating.title_id

loop
insert into tt(pid, person_rating) values(rec.person_id, trunc((rec.vote_count*rec.average_rating)/(rec.vote_count), 1));

/*
update person
SET person_average_rating = trunc(person_average_rating + tempval/(select count(rec.person_id) from related_title_actors where related_title_actors.person_id = rec.person_id), 1) from related_title_actors where related_title_actors.person_id = rec.person_id;*/

end loop;
with rating_cte as 
(select (sum(tt.person_rating)/count(tt.person_rating)) as rat, tt.pid as avg1 from tt group by tt.pid) 

UPDATE person SET person_average_rating = rat 
FROM rating_cte WHERE rating_cte.avg1 = person.person_ID; 
END;
$$ 

-- if using above code the sum of John cleese is 328.9 and the average_rating is (8,0)
SELECT pid, SUM(weighted_rating) / SUM(total_votes) AS final_rating
FROM tt WHERE pid = 'nm0000092' GROUP BY pid;
SELECT * FROM PERSON WHERE PERSON_ID='nm0000092';

SELECT person_average_rating FROM person WHERE person_id= 'nm0000092';
SELECT * FROM tt WHERE pid = 'nm0000092';
SELECT sum(person_rating) from tt where pid='nm0000092';

SELECT primary_name FROM person WHERE person_id='nm0000092';
SELECT COUNT(person_id) FROM related_title_actors WHERE person_id = 'nm5380976';


/* TEST QUERY THAT LOOKS LIKE IT WORK! */
DO $$ 
DECLARE 
    rec RECORD;
    tempval NUMERIC;
BEGIN
    -- Drop and create a temporary table to store intermediate values
    DROP TABLE IF EXISTS tt;
    CREATE TEMP TABLE tt (pid VARCHAR, weighted_rating NUMERIC, total_votes INT);

    -- Loop through the related titles and ratings
    FOR rec IN 
        SELECT person_id, vote_count, average_rating 
        FROM related_title_actors 
        NATURAL JOIN rating 
        WHERE related_title_actors.title_id = rating.title_id
    LOOP
        -- Insert the weighted rating and the vote count for each person
        INSERT INTO tt(pid, weighted_rating, total_votes) 
        VALUES(rec.person_id, rec.vote_count * rec.average_rating, rec.vote_count);
    END LOOP;

    -- Use a CTE to calculate the weighted average for each person
    WITH rating_cte AS (
        SELECT 
            pid, 
            SUM(weighted_rating) / SUM(total_votes) AS final_rating
        FROM tt
        GROUP BY pid
    )

    -- Update the person's average rating in the 'person' table
    UPDATE person
    SET person_average_rating = rating_cte.final_rating
    FROM rating_cte 
    WHERE rating_cte.pid = person.person_ID;

END $$;


