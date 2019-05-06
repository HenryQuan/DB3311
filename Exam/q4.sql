-- This one is interesting
drop view if exists q4;
create view if not exists q4 as
with Match as (select T.country as One, T.country as Two from Teams as T, Involves as F join Involves as S on
F.match = S.match where T.country > T.country),
TopMatch as (select One, Two, Count(*) as C from Match group by One, Two)
select T.One, T.Two, T.C from TopMatch as T
join (select max(C) as most from TopMatch) as M on T.C = M.most;