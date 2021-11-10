-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS country_election CASCADE;
DROP VIEW IF EXISTS decreasing CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.
-- find average votes cast for each country between 2001 and 2016
CREATE VIEW country_election AS
SELECT name AS countryName,EXTRACT(YEAR FROM e_date) AS year,avg(CAST(votes_cast AS FLOAT)/electorate) AS participationRatio
FROM country, election
WHERE country.id = election.country_id AND (EXTRACT(year FROM e_date) between 2001 and 2016)
AND (CAST(election.votes_cast AS FLOAT)/election.electorate) IS NOT NULL
GROUP BY name, EXTRACT(year FROM e_date);

-- find countries with decreasing participation ratios
CREATE VIEW decreasing AS
SELECT DISTINCT ce1.countryName
FROM country_election ce1 JOIN country_election ce2 ON ce1.countryName = ce2.countryName
WHERE ce1.year > ce2.year AND ce1.participationRatio < ce2.participationRatio;

CREATE VIEW result AS
SELECT countryName, year, participationRatio
FROM country_election
WHERE country_election.countryName NOT IN 
    (SELECT countryName
    FROM decreasing);

-- the answer to the query 
insert into q3
SELECT *
FROM result;
