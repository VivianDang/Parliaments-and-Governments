-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS winner CASCADE;
DROP VIEW IF EXISTS average_winning CASCADE;
DROP VIEW IF EXISTS party_win CASCADE;
DROP VIEW IF EXISTS three_party CASCADE;
DROP VIEW IF EXISTS temp CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.

-- find all winner parties
create view winner as 
select r1.id , r1.party_id, r1.election_id, election.country_id, e_date
from election_result as r1 JOIN election on election.id = r1.election_id
where not exists (select * from election_result as r2 
                        where r2.id != r1.id and 
                              r2.election_id = r1.election_id and
                              r2.votes > r1.votes and
                              r2.votes is not null) and
      r1.votes is not null;

-- find the average number of winning elections of parties in the same country
create view average_winning as
select winner.country_id, 
      (cast(count(winner.id)as float) / (select count(party.id) from party
                                  where party.country_id = winner.country_id)) as average_winning_count
from winner
group by winner.country_id;

-- Find parties that have won more than 3 times the average number of winning elections
create view party_win as
select party_id, count(id), country_id, max(e_date) as last_election 
from winner 
group by party_id, country_id;

create view three_party as
select party_win.party_id, party_win.count, party_win.country_id, party_win.last_election
from party_win join average_winning on party_win.country_id = average_winning.country_id
where party_win.count > average_winning_count * 3;

-- find other info we need
create view temp as 
select * from three_party natural left join party_family;

create view result as
select country.name as countryName, 
       party.name as partyName, 
       family as partyFamily, 
       temp.count as wonElections, 
       winner.election_id as mostRecentlyWonElectionId, 
       (cast(extract(year from temp.last_election) as int)) as mostRecentlyWonElectionYear   
from temp join country on country.id = temp.country_id
     join party on party.id = temp.party_id
     join winner on winner.e_date = temp.last_election
where winner.party_id = temp.party_id;

-- the answer to the query 
insert into q2 
select * from result;
