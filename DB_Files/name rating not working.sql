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

update person
set person_average_rating = rat from rating_cte where rating_cte.avg1 = person.person_ID; 
end;
$$ 

select sum(person_rating) from tt where pid = 'nm0000092';
select person_average_rating from person where person_id= 'nm0000092'
select * from tt where pid = 'nm0000092'
select primary_name from person  where person_id='nm0000092'
select count(person_id) from related_title_actors where person_id = 'nm5380976'


update person
set person_average_rating = 0
select * from person order by  person_average_rating asc