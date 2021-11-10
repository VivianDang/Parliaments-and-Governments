-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinet_20 CASCADE;
DROP VIEW IF EXISTS all_cabinet CASCADE;
DROP VIEW IF EXISTS cabinet_count CASCADE;
DROP VIEW IF EXISTS commited CASCADE;
DROP VIEW IF EXISTS result CASCADE;


-- Define views for your intermediate steps here.

-- find cabinets in recent 20 years
CREATE VIEW cabinet_20 AS
SELECT id, country_id, previous_cabinet_id, start_date
FROM cabinet
WHERE EXTRACT(YEAR FROM start_date) between 1997 AND 2016;

CREATE VIEW all_cabinet AS
SELECT DISTINCT cabinet.id, cabinet.country_id
FROM cabinet, cabinet_20 
WHERE cabinet.id = cabinet_20.id
    OR (cabinet.id = cabinet_20.previous_cabinet_id
        AND cabinet_20.start_date != '1997-01-01');

-- count how many cabinets in each country
CREATE VIEW cabinet_count AS
SELECT country_id, count(*)
FROM all_cabinet
GROUP BY country_id;

-- find committed parties which have been in cabinets over recent 20 years
CREATE VIEW committed AS
SELECT party_id,country_id,count(*)
FROM all_cabinet JOIN cabinet_party ON all_cabinet.id = cabinet_party.cabinet_id
GROUP BY party_id, country_id
HAVING count(*)=(SELECT count
                 FROM cabinet_count
                 WHERE all_cabinet.country_id = cabinet_count.country_id);

CREATE VIEW result AS
SELECT country.name AS countryName, party.name AS partyName, party_family.family AS partyFamily, party_position.state_market AS stateMarket
FROM (committed NATURAL LEFT JOIN party_family)
     JOIN party ON committed.party_id = party.id
     JOIN country ON committed.country_id=country.id
     JOIN party_position ON party_position.party_id = committed.party_id;

-- the answer to the query 
insert into q5
select * from result;