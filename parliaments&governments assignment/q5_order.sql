SET SEARCH_PATH TO parlgov;

SELECT * 
FROM q5
ORDER BY countryName, partyName, stateMarket DESC;