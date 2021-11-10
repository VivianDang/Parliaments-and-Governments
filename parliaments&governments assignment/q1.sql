-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_years CASCADE;
DROP VIEW IF EXISTS party_election CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.

-- find election info we need in the years between 1996 and 2016
create view election_years as
select id as election_id, country_id, extract(year from e_date) as year, votes_valid
from election
where extract(year from e_date) between 1996 and 2016
order by year; 

-- combine election result and votes with each party and country
CREATE VIEW party_election AS
SELECT party.name_short AS partyName, sum(election_result.votes) as votes, country.name AS countryName, sum(election.votes_valid) as votes_valid, election_years.year
FROM election_result JOIN party ON election_result.party_id = party.id
                     JOIN election ON election.id = election_result.election_id
                     JOIN country ON country.id = party.country_id
                     JOIN election_years ON election_years.year = EXTRACT(year FROM election.e_date)
GROUP BY countryName, partyName, year
ORDER BY countryName, year, partyName; 


CREATE VIEW result AS 
SELECT year, countryName, partyName,
	(CASE 
		WHEN (CAST (votes AS FLOAT)/votes_valid>0) AND (CAST (votes AS FLOAT)/votes_valid <= 0.05) THEN  '(0,5]'
		WHEN CAST (votes AS FLOAT)/votes_valid BETWEEN 0.05 AND 0.1 THEN '(5-10]'
		WHEN CAST (votes AS FLOAT)/votes_valid BETWEEN 0.10 AND 0.20 THEN '(10-20]'
		WHEN CAST (votes AS FLOAT)/votes_valid BETWEEN 0.20 AND 0.30 THEN '(20-30]'
		WHEN CAST (votes AS FLOAT)/votes_valid BETWEEN 0.30 AND 0.40 THEN '(30-40]'
		WHEN CAST (votes AS FLOAT)/votes_valid BETWEEN 0.40 AND 1.00 THEN '(40-100]'

		ELSE NULL
	END) AS voteRange
	FROM party_election;


-- the answer to the query 
insert into q1 
SELECT year, countryName, voteRange, partyName
FROM result;
