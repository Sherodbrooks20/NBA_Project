-- write more detailed comments

-- update excel files 
-- changing column names
update who_should_nba_teams_draft.`copy of player(updated)`
set position = 'Wing'
where position = 'G-F';

update who_should_nba_teams_draft.`copy of player(updated)`
set position = 'Wing'
where position = 'F-G';

update who_should_nba_teams_draft.`copy of player(updated)`
set position = 'Big'
where position = 'F-C';

update who_should_nba_teams_draft.`copy of player(updated)`
set position = 'Big'
where position = 'C-F';

-- altering a column name
-- alter table who_should_nba_teams_draft.`copy of players_height_weight(updated)`
-- rename column collage to college;

-- exploration/ analyze

SELECT * 
FROM who_should_nba_teams_draft.`copy of player(updated)`;

select *
from who_should_nba_teams_draft.`copy of players_height_weight(updated)`;


SELECT *
FROM who_should_nba_teams_draft.`copy of seasons(updated)`;

-- combine the players data from the same player in multiple seasons 
select distinct player
FROM who_should_nba_teams_draft.`copy of seasons(updated)`;

-- or 
select player
FROM who_should_nba_teams_draft.`copy of seasons(updated)`
group by player;

---------------------------------------------------------------

select * 
from nba_draft_data_table;

-- join players table to the main stats, player measurable tables by making them temp tables
drop table players; 
create temporary table players as 
select 
name, year_start, (year_end - (year_start)+1) as num_of_years_played, year_end, position, college
FROM who_should_nba_teams_draft.`copy of player(updated)`
order by num_of_years_played desc;

drop table players_measure;
create temporary table players_measure as 
select row_number() over() as p_id, 
player, 
round((height * 0.0328),1) as height, 
(weight * 2.2) as weight, 
college,
birth_city,
birth_state
from who_should_nba_teams_draft.`copy of players_height_weight(updated)`
order by height;

drop table main_stats;
create temporary table main_stats as
select player, g, gs, mpg, ppg, asg, rbg, fg, 3P, 2p, ft, stl, blk
from 
(
select player, g, gs, mpg, round(ppg,2) as ppg,
round(asg,2) as asg, round(rbg,2) as rbg, 
round(`fg/dis`,2) as fg, round(3PPercentage,2) as 3P, round(`2p/dis`,2) as 2p, round(`FT/dis`,2) as ft,
round(`stl/dis`,2) as stl, round(`blk/dis`,2) as blk
FROM who_should_nba_teams_draft.`copy of seasons(updated)`
group by player
) x;


select *
from players;

update players 
set position = 'Big'
where position = 'C';

update players 
set position = 'Wing'
where position = 'F';

update players 
set position = 'Guard'
where position = 'g';


select *
from players_measure;

select *
from main_stats;

-- joining all the tables on one temp table
drop table nba_data;
create temporary table nba_data as 
select ms.player,ms.g,ms.gs, pm.height, pm.weight, pm.college, 
ms.mpg,ms.ppg, ms.asg, ms.rbg, ms.fg, ms.`3P`, ms.`2p`, ms.ft
from main_stats as ms
left outer join players_measure as pm
on ms.player = pm.player;


select *
from nba_data
order by mpg desc;




-- looking at the difference in major stats by position
select position, round(avg(ppg),2) as ppg, round(avg(asg),2) as asg, round(avg(rbg),2) as rbg, 
round(avg(fg),2) as fg, round(avg(`3P`),2) as 3p, round(avg(ft),2) as ft
from nba_data
where gs >=41
group by position;

select position, round(avg(ppg),2) as ppg, round(avg(asg),2) as asg, round(avg(rbg),2) as rbg, 
round(avg(fg),2) as fg, round(avg(`3P`),2) as 3p, round(avg(ft),2) as ft
from nba_data
where gs <= 41
group by position;



-- advanced stats 

SELECT * 
FROM who_should_nba_teams_draft.`copy of seasons(updated)`;

drop table advanced_stats;
create temporary table advanced_stats as 
select Year, Player, Pos, GS, round(MPG,2) as MPG, PER,  round(`TS%`, 2) as TS, round(`USG%`,2) as USG, WS, round(`FG%`,2) as FG,
round(`3PPercentage`, 2) as `3p`, round(`2P/Dis`, 2) as `2p`, round(`eFG%`, 2) as `eFG%`, round(FTPercentage, 2) as FT,
round(TOV/G, 2) as TOV, round(PFG, 2) as PFG
FROM who_should_nba_teams_draft.`copy of seasons(updated)`;

select * 
from advanced_stats;
