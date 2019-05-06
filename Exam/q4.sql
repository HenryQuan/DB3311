-- This one is interesting
with Match as (select F.team as One, S.team as Two from Involves as F join Involves as S on
F.match = S.match where F.team > S.team order by F.team, S.team)
select One, Two, Count(*) as C from Match
group by One, Two order by C desc;