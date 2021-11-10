-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinetDate CASCADE;
DROP VIEW IF EXISTS partypm CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.

-- find info of cabinets according to their start and end date
CREATE VIEW cabinetDate AS
SELECT c1.country_id, c1.id AS cabinet_id, c1.start_date AS startDate, c2.start_date AS endDate
FROM cabinet c1 LEFT JOIN cabinet c2 ON c1.id = c2.previous_cabinet_id;

-- party that fills position of pm
CREATE VIEW partypm AS
SELECT cd.country_id, cd.cabinet_id, cd.startDate, cd.endDate, cp.party_id
FROM cabinetDate cd LEFT JOIN cabinet_party cp ON cd.cabinet_id = cp.cabinet_id AND cp.pm = 'true';


CREATE VIEW result AS
SELECT country.name AS countryName, partypm.cabinet_id AS cabinetId, partypm.startDate AS startDate, partypm.endDate AS endDate, party.name AS pmParty
FROM partypm LEFT JOIN party ON party.id = partypm.party_id
             JOIN country ON country.id = partypm.country_id;

-- the answer to the query 
insert into q6 
select * from result;