-- This one is interesting
with Match as (select F.team as One, S.team as Two from Involves as F join Involves as S on
F.match = S.match where F.team > S.team),
TopMatch as (select One, Two, Count(*) as C from Match group by One, Two)
select F.country, S.country, T.C from Teams as F, Teams as S
join TopMatch as T on T.One = F.id and T.Two = S.id and T.C = (select max(C) from TopMatch);