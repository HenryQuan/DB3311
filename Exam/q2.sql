drop view if exists q2;
create view if not exists q2 as
with Amazing as (select scoredBy, count(*) as Goal from goals group by scoredBy having rating = 'amazing')
select P.name as player, A.Goal as goals from Players as P join Amazing as A on
P.id = A.scoredBy