drop view if exists q3;
create view if not exists q3 as
with G as (select scoredBy from goals),
T as (select memberOf, count(*) as C from players where id not in G group by memberOf order by C desc limit 1)
select E.country, T.C from Teams as E join T on
E.id = T.memberOf;