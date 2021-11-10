-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_party CASCADE;
DROP VIEW IF EXISTS alliance CASCADE;
DROP VIEW IF EXISTS alliance_pair CASCADE;
DROP VIEW IF EXISTS country_count CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW election_party AS
SELECT DISTINCT er.party_id AS party_id, er.election_id, election.country_id, er.id, er.alliance_id
FROM election_result er JOIN election ON er.election_id = election.id;

-- find pairs of alllied parties
CREATE VIEW alliance AS
SELECT DISTINCT ep1.party_id AS party_id1, ep2.party_id AS party_id2, ep1.election_id, ep1.country_id
FROM election_party ep1, election_party ep2
WHERE ep1.party_id < ep2.party_id AND 
    (ep1.id = ep2.alliance_id
     OR ep1.alliance_id = ep2.alliance_id
     OR ep1.alliance_id=ep2.id);

-- count pairs of parties that have been allied with each other
CREATE VIEW alliance_pair AS
SELECT party_id1, party_id2, country_id, count(election_id)
FROM alliance
GROUP BY party_id1, party_id2, country_id;

-- count electons that have happened in a country
CREATE VIEW country_count AS
SELECT country_id, count(id)
FROM election
GROUP BY country_id;

CREATE VIEW result AS
SELECT ap.country_id AS countryId, ap.party_id1 AS alliedPartyId1, ap.party_id2 AS alliedPartyId2
FROM alliance_pair ap JOIN country_count cc ON ap.country_id = cc.country_id
WHERE ap.count >= 0.3*(cc.count);

-- the answer to the query 
insert into q7
SELECT * FROM result;