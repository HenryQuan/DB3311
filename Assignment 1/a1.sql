/*
    This is the first assignment for COMP3311 19T1
    Yiheng Quan z5098268
*/

-- Q1
-- List all the company names (and countries) that are incorporated outside Australia.
create or replace view Q1(Name, Country) as
select Name, Country from Company                  
where Country != 'Australia';

-- Q2 
-- List all the company codes that have more than five executive members on record (i.e., at least six).
create or replace view Q2(Code) as
select Code from Executive
group by Code
-- You need to use having while using functions
having Count(*) > 5;

-- Q3
-- List all the company names that are in the sector of "Technology"
create or replace view Q3(Name) as
select C.Name from Category as T, Company as C
where T.Sector = 'Technology' and T.Code = C.Code;

-- Q4
-- Find the number of Industries in each Sector
create or replace view Q4(Sector, Number) as
select Sector, Count(*) from 
(select Sector, Industry from Category group by Sector, Industry) as One
group by Sector order by Sector;

-- Q5
-- Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". If an
-- executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of
-- "Technology".
create or replace view Q5(Name) as
select E.Person from Executive as E, Category as C
where C.Sector = 'Technology' and C.Code = E.Code;

-- Q6
-- List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code
-- being 2.
create or replace view Q6(Name) as
select C.Name from Company as C, Category as T
where C.Country = 'Australia' and C.Zip like '2%' and T.Sector = 'Services' and C.Code = T.Code;

-- Q7
-- Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and
-- Price gain (in percentage, can be negative). (Note that the first trading day should be excluded in your result.) For
-- example, if the PrevPrice is 1.00, Price is 0.85; then Change is -0.15 and Gain is -15.00 (in percentage but you do not
-- need to print out the percentage sign).
create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as
with am as (select "Date", Code, Volume, lag(Price, 1) over (partition by Code order by "Date") as old, Price, price - lag(Price, 1) over (partition by Code order by "Date") as change, (price - lag(Price, 1) over (partition by Code order by "Date")) / lag(Price, 1) over (partition by Code order by "Date") * 100 as gain from ASX)
select * from am
where old is not null;

-- Q8
-- Find the most active trading stock (the one with the maximum trading volume; if more than one, output all of them) on
-- every trading day. Order your output by "Date" and then by Code.
create or replace view Q8("Date", Code, Volume) as
select M."Date", A.Code, M.V from
(select "Date", Max(Volume) as V from ASX
group by "Date" order by "Date") as M, ASX as A
where M.V = A.Volume;

-- Q9
-- Find the number of companies per Industry. Order your result by Sector and then by Industry.
create or replace view Q9(Sector, Industry, Number) as
select Sector, Industry, Count(*) from Category
group by Industry, Sector
order by Sector, Industry;

-- Q10
-- List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).
create or replace view Q10(Code, Industry) as
select C.Code, M.Industry from Category as C, (select Industry from Category group by Industry having Count(*) = 1) as M
where C.Industry = M.Industry;

-- Q11
-- List all sectors ranked by their average ratings in descending order. AvgRating is calculated by finding the average
-- AvgCompanyRating for each sector (where AvgCompanyRating is the average rating of a company).
create or replace view Q11(Sector, AvgRating) as
select C.Sector, Avg(R.star) from Category as C, Rating as R
where C.Code = R.Code
group by C.Sector;

-- Q12
-- Output the person names of the executives that are affiliated with more than one company.
create or replace view Q12(Name) as
select Person from Executive
group by Person
having Count(*) > 1
order by Person;

-- Q13
-- Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the
-- same Sector. i.e., they are in a Sector that all companies there have local Australia address.
create or replace view Q13(Code, Name, Address, Zip, Sector) as
-- Count number of entry in Category and Australian companies
select C.Code, C.Name, C.Address, C.Zip, T.Sector from Company as C, Category as T, (select T.Sector from Category as T, Company as C where C.Code = T.Code group by T.Sector having count(case C.Country when 'Australia' then 1 else null end) = count(T.*)) as M
where C.Code = T.Code and T.Sector = M.Sector;

-- Q14
-- Calculate stock gains based on their prices of the first trading day and last trading day (i.e., the oldest "Date" and the
-- most recent "Date" of the records stored in the ASX table). Order your result by Gain in descending order and then by
-- Code in ascending order.
create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as
with D as (select Code, min("Date"), max("Date") from ASX group by Code)
select OD.Code, OD.FP, A.Price as LF, (A.Price - OD.FP) as Diff, (A.Price - OD.FP) / OD.FP * 100 as Gain from ASX as A, (select D.*, A.Price as FP from ASX as A, D where A."Date" = D.min and A.Code = D.Code) as OD
where A."Date" = OD.max and A.Code = OD.Code
order by Gain desc, Code asc;

-- Q15
-- For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is
-- measured in percentage). AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by
-- the number of trading days (as noted above, the total number of days here should exclude the first trading day).
create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as
with GD as (select A.* from ASX as A, (select min("Date") from ASX) as MD where A."Date" != MD.min), FH as (select Code, min(Price), avg(Price), max(Price) from GD group by Code),
R as (select Code, count(*), min(Gain), avg(Gain), max(Gain) from Q7 group by Code)
select FH.*, R.min, R.avg, R.max from FH
inner join R on R.Code = FH.Code;

-- Q16
-- Create a trigger on the Executive table, to check and disallow any insert or update of a Person in the Executive table to
-- be an executive of more than one company.
create or replace function 
    Q16() returns trigger
as $$
begin
    select Person from Executive
    group by Person
    having Count(*) > 1
    order by Person;
    if then
    end if
    return null;
end;
$$ language 'plpgsql';

-- Q17
-- Suppose more stock trading data are incoming into the ASX table. Create a trigger to increase the stock's rating (as
-- Star's) to 5 when the stock has made a maximum daily price gain (when compared with the price on the previous
-- trading day) in percentage within its sector. For example, for a given day and a given sector, if Stock A has the
-- maximum price gain in the sector, its rating should then be updated to 5. If it happens to have more than one stock with
-- the same maximum price gain, update all these stocks' ratings to 5. Otherwise, decrease the stock's rating to 1 when the
-- stock has performed the worst in the sector in terms of daily percentage price gain. If there are more than one record of
-- rating for a given stock that need to be updated, update (not insert) all these records.
create or replace function 
    Q17() returns trigger
as $$
begin
    return null;
end;
$$ language 'plpgsql';

-- Q18
-- Stock price and trading volume data are usually incoming data and seldom involve updating existing data. However,
-- updates are allowed in order to correct data errors. All such updates (instead of data insertion) are logged and stored in
-- the ASXLog table. Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates
-- (only for update, not inserts) into the ASXLog table. Here we assume that Date and Code cannot be corrected and will
-- be the same as their original, old values. Timestamp is the date and time that the correction takes place. Note that it is
-- also possible that a record is corrected more than once, i.e., same Date and Code but different Timestamp.
create or replace function 
    Q18() returns trigger
as $$
begin
    return null;
end;
$$ language 'plpgsql';
