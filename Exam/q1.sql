drop view if exists q1;
create view if not exists q1 as
with C as (select team, count(*) as Num from involves group by team)
select T.country as team, C.Num as matches from Teams as T join C on
T.id = C.team;