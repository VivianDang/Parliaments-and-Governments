-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS party_lr CASCADE;
DROP VIEW IF EXISTS r0_2_party CASCADE;
DROP VIEW IF EXISTS r2_4_party CASCADE;
DROP VIEW IF EXISTS r4_6_party CASCADE;
DROP VIEW IF EXISTS r6_8_party CASCADE;
DROP VIEW IF EXISTS r8_10_party CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.

-- Info of parties that have left_right position
create view party_lr as 
select party.country_id, party.id, party_position.left_right
from party, party_position
where party.id = party_position.party_id;


create view r0_2_party as
select country_id, count(left_right)
from party_lr
where left_right >= 0 AND left_right < 2
group by country_id;

create view r2_4_party as
select country_id, count(left_right)
from party_lr
where left_right >= 2 AND left_right < 4
group by country_id;

create view r4_6_party as
select country_id, count(left_right)
from party_lr
where left_right >= 4 AND left_right < 6
group by country_id;

create view r6_8_party as
select country_id, count(left_right)
from party_lr
where left_right >= 6 AND left_right < 8
group by country_id;

create view r8_10_party as
select country_id, count(left_right)
from party_lr
where left_right >= 8 AND left_right < 10
group by country_id;

create view result as
select country.name as countryName, r0_2_party.count as r0_2, r2_4_party.count as r2_4, r4_6_party.count as r4_6, r6_8_party.count as r6_8, r8_10_party.count as r8_10
from r0_2_party natural join r2_4_party natural join r4_6_party natural join r6_8_party natural join r8_10_party 
                join country on r0_2_party.country_id = country.id;

-- the answer to the query 
INSERT INTO q4 
select * from result;