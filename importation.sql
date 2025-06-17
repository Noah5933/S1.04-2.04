DROP TABLE IF EXISTS import, noc, athlete, event, game, performance, Participants, Medailles, Femmes ;

-- Partie BDD

CREATE temp TABLE import(
    ID int,
    Name varchar(150),
    Sex char(1),
    Age int,
    Height int,
    Weight float,
    Team varchar(150),
    NOC char(3),
    Games char(11),
    Year int,
    Season char(6),
    City varchar(150),
    Sport varchar(150),
    Event varchar(150),
    Medal varchar(10)
);

CREATE TABLE noc (
    NOC char(3),
    region varchar(100),
    notes varchar(100),
    CONSTRAINT pk_noc PRIMARY KEY (NOC)
);

\COPY import from 'athlete_events.csv' DELIMITER ',' header csv NULL AS 'NA';
\COPY noc FROM 'noc_regions.csv' DELIMITER ',' header csv;

DELETE FROM import WHERE Event LIKE 'Art%';
DELETE FROM import WHERE Year < 1920;

SELECT COUNT(*) AS LignesImport FROM import;

SELECT COUNT(*) AS LignesNOC FROM noc;

SELECT COUNT(DISTINCT ID) AS AthletesDifferents FROM import;

SELECT COUNT(*) AS nbMedailles, medal FROM import GROUP BY medal;

SELECT COUNT(*) AS LignesCarlLewis FROM import WHERE id=69210;

CREATE TABLE athlete (id int PRIMARY KEY, name text, sex char) ;

CREATE TABLE event(id serial PRIMARY KEY, event text, sport text);

CREATE TABLE game (id serial PRIMARY KEY, game text, YEAR int, season text, city text) ;
 
CREATE TABLE performance(
 id_athlete int REFERENCES athlete(id),
 id_event int REFERENCES event(id),
 id_game int REFERENCES game(id),
 noc text REFERENCES noc(NOC),
 medal text, age int ,weight float ,height int,
 PRIMARY KEY(id_athlete, id_event, id_game, noc));

INSERT INTO athlete
 SELECT DISTINCT id,name,sex
 FROM import;
  
INSERT INTO event(event,sport)
 SELECT DISTINCT event,sport FROM import;
 
INSERT INTO game(game,YEAR,season,city)
 SELECT DISTINCT Games,YEAR,season,city FROM import;
 
INSERT INTO performance
 SELECT p.id,e.id, G.id,n.noc,medal,age,weight,height
 FROM import p,noc n, event e,game G
 WHERE p.noc=n.noc
 AND p.event=e.event AND p.sport=e.sport
 AND G.game=p.Games AND G.YEAR=p.YEAR AND G.season=p.season 
 AND G.city=p.city;

/*
SELECT id_athlete, athlete.name ,COUNT(DISTINCT id_game) AS nombre_jeux_jouées
FROM performance, athlete 
WHERE athlete.id = performance.id_athlete 
GROUP BY id_athlete, athlete.name
ORDER BY nombre_jeux_jouées DESC 
LIMIT 20;

select noc.region, avg(age), count(id_athlete), min(age), max(age)
from performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964
GROUP BY noc.region;

-- Q2.1

COPY (select noc.region, round(avg(age),2), count(id_athlete), min(age), max(age) 
from performance, game, noc 
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964 
GROUP BY noc.region) 
TO '/home/user/bdd/1964_winter.csv' WITH  CSV HEADER;

-- Q2.2
-- everyone
select round(avg(age),2) as AVGeveryone
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964
group by game.year;

-- medal
select round(avg(age),2) as medal
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964  and performance.medal in ('Gold','Silver','Bronze')
group by game.year;

-- Q2.3 Female

-- Medal

select avg(weight) as medal_female
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964  and performance.medal in ('Gold','Silver','Bronze') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

-- No Medal

select avg(weight) as no_medal_female
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964  and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

-- Male

-- Medal

select avg(weight) as medal_male
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964  and performance.medal in ('Gold','Silver','Bronze') and performance.id_athlete = athlete.id and sex = 'M'
group by game.year;

-- No Medal

select avg(weight) as no_medal_male
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.season like '%Winter' and game.year = 1964  and performance.id_athlete = athlete.id and sex = 'M'
group by game.year;
-- Q3

SELECT COUNT(*) AS nbMedailles, noc.region
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.medal in ('Gold','Silver','Bronze')
GROUP BY  noc.region
order by nbMedailles DESC
limit 15;
*/
-- Q3.2.1

select count(DISTINCT id_athlete) as japan, game.year
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN'
group by game.year;

select count(DISTINCT id_athlete) as USA
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'USA'
group by game.year;

select count(DISTINCT id_athlete) as France
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'FRA'
group by game.year;

select count(DISTINCT id_athlete) as Germany
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'GER'
group by game.year;

select count(DISTINCT id_athlete) as Russia
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'RUS'
group by game.year;
/*
-- Q3.2.2

select count(*) as japan
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN' and medal not in ('NA')
group by game.year;

select count(*) as china
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'CHN' and medal not in ('NA')
group by game.year;

select count(*) as south_korea
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'KOR' and medal not in ('NA')
group by game.year;

select count(*) as netherlands
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'NED' and medal not in ('NA')
group by game.year;

select count(*) as Sweden
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'SWE' and medal not in ('NA')
group by game.year;

-- Q3.2.3

select count(*) as japan
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as china
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'CHN' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as south_korea
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'KOR' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as netherlands
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'NED' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as Sweden
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'SWE' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

-- Q3.2.4

-- Requete precedante + H = Nbtotal/nbFemme

select count(*) as japan
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN' and performance.id_athlete = athlete.id and sex = 'M'
group by game.year;

select count(*) as china
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'CHN' and performance.id_athlete = athlete.id and sex = 'M'
group by game.year;

select count(*) as south_korea
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'KOR' and performance.id_athlete = athlete.id and sex = 'M'
group by game.year;

select count(*) as netherlands
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'NED' and performance.id_athlete = athlete.id and sex = 'M'
group by game.year;

select count(*) as Sweden
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'SWE' and performance.id_athlete = athlete.id and sex = 'M'
group by game.year;
*/
-- Q3.2.5

-- NbFemme

select count(*) as japan_NbFemme
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as china
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'CHN' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as south_korea
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'KOR' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as netherlands, game.year
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'NED' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as Sweden
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'SWE' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year; 

--Nbmedal

select count(*) as japan
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN' and medal not in ('NA')
group by game.year;

select count(*) as china
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'CHN' and medal not in ('NA')
group by game.year;

select count(*) as south_korea
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'KOR' and medal not in ('NA')
group by game.year;

select count(*) as netherlands, game.year
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'NED' and medal not in ('NA')
group by game.year;

select count(*) as Sweden
FROM performance, game, noc
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'SWE' and medal not in ('NA')
group by game.year;

-- Q3.2.6

--NbFemmeMedal

select count(*) as japan_NbFemmeMedal
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as china
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'CHN' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as south_korea
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'KOR' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as netherlands, game.year
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'NED' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(*) as Sweden
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'SWE' and medal not in ('NA') and performance.id_athlete = athlete.id and sex = 'F'
group by game.year; 

--NbFemme

select count(DISTINCT id_athlete) as japan
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'JPN' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(DISTINCT id_athlete) as china
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'CHN'and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(DISTINCT id_athlete) as south_korea
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'KOR' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(DISTINCT id_athlete) as netherlands
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'NED' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year;

select count(DISTINCT id_athlete) as Sweden
FROM performance, game, noc, athlete
where performance.id_game = game.id and performance.noc = noc.noc and game.year between 1992 and 2016 and performance.noc = 'SWE' and performance.id_athlete = athlete.id and sex = 'F'
group by game.year; 