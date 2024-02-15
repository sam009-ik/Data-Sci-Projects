SELECT COUNT(*) FROM people;
SELECT COUNT(*) FROM batting;

--'people' table has 28 columns
select COUNT(*) from information_schema.columns
where table_name = 'people';
SELECT * FROM people LIMIT 5;
--'batting' has 25 columns
select COUNT(*) from information_schema.columns
where table_name = 'batting';
SELECT * FROM batting limit 5;

--'pitching' has 32 colummns
select COUNT(*) from information_schema.columns
where table_name = 'pitching';
SELECT * FROM pitching LIMIT 5;

--'teams' has 50 columns
SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'teams';
SELECT * FROM teams LIMIT 5;

--Since they dont have the same number of columns,
--we cannot use UNION ALL tosee 10 rows each from these multiple tables

--The Best of Baseball Awards

--1. Heaviest Hitter--
--This award goes to the team with the highest average weight of its batters on a given year
SELECT 
	batting.yearid, teams.name AS team_name, AVG(people.weight) AS avg_batter_weight
FROM people 
	JOIN batting ON people.playerid = batting.playerid
	JOIN teams ON batting.teamid = teams.teamid	
GROUP BY
	batting.yearid,
	teams.name
ORDER BY
	batting.yearid,
	AVG(people.weight) DESC;

--2. Shortest Sluggers: This award goes to the team with the smallest average height of its batters on a given year.--
SELECT 
	batting.yearid, teams.name AS team_name, AVG(people.height) AS avg_batter_height
FROM people
	JOIN batting ON people.playerid = batting.playerid
	JOIN teams ON batting.teamid = teams.teamid
GROUP BY 
	batting.yearid,
	teams.name
ORDER BY
	batting.yearid,
	avg_batter_height;
	
--3. Biggest Spenders:-- 
--This award goes to the team with the largest total salary of all players in a given year.--
SELECT * FROM salaries LIMIT 10;

SELECT 
	salaries.yearid, teams.name AS team_name, SUM(salaries.salary) AS total_salary
FROM salaries
	JOIN teams ON salaries.teamid = teams.teamid
GROUP BY 
	salaries.yearid,
	team_name
ORDER BY
	salaries.yearid,
	total_salary DESC;

--If i just wanted to see the top team in each year
WITH ranked_teams AS (
	SELECT
		salaries.yearid, 
		teams.name AS team_name,
		SUM(salaries.salary) AS total_salary,
		ROW_NUMBER() OVER (PARTITION BY salaries.yearid ORDER BY SUM(salaries.salary) DESC) AS rn
	FROM salaries 
	JOIN teams ON salaries.teamid = teams.teamid
	GROUP BY
		salaries.yearid,
		teams.name
)
SELECT 
	yearid, 
	team_name, 
	total_salary
FROM ranked_teams
WHERE rn = 1
ORDER BY yearid;
--This is much more precise as we know exactly who the Award goes to--

--4. Most Bang For Their Buck in 2010--
--This award goes to the team that had the smallest "cost per win" in 2010--
SELECT
	teams.yearid,
	teams.name AS team_name,
	SUM(salaries.salary) AS total_salary,
	teams.w AS wins,
	(SUM(salaries.salary) / teams.w) AS cost_per_win
FROM salaries 
	JOIN teams ON salaries.teamid = teams.teamid AND salaries.yearid = teams.yearid
WHERE salaries.yearid = 2010
GROUP BY
	teams.yearid,
	teams.name,
	teams.w
ORDER BY 
	cost_per_win;

--Both approaches work--
/*
SELECT 
	teams.name AS team_name,
	SUM(salaries.salary) / teams.w AS cost_per_win
FROM salaries
	JOIN teams ON salaries.teamid = teams.teamid AND salaries.yearid = teams.yearid
WHERE salaries.yearid = 2010
GROUP BY
	teams.name,
	teams.w
ORDER BY cost_per_win;
*/

--5. Priciest Starter--
--This award goes to the pitcher who, in a given year, cost the most money per game in which they were the
--starting pitcher. Note that many pitchers only started a single game, so to be eligible for this award, you had to
--start at least 10 games.
/*
SELECT 
	yearid,
	player_name,
	MAX(cost_per_game_started) AS max_cost_per_game_started
FROM (
	SELECT 
		salaries.yearid, 
		SUM(pitching.gs) AS total_games_started,
		SUM(salaries.salary) AS total_salary,
		people.namegiven AS player_name,
		SUM(salaries.salary) / SUM(pitching.gs) AS cost_per_game_started
	FROM salaries
		JOIN pitching ON salaries.playerid = pitching.playerid 
			AND salaries.teamid = pitching.teamid 
			AND salaries.yearid = pitching.yearid
		JOIN people ON pitching.playerid = people.playerid
	WHERE pitching.gs >= 10
	GROUP BY 	
		salaries.yearid,
		people.namegiven
) AS subquery
GROUP BY yearid
ORDER BY yearid;
*/
	
--Code from gpt4--
WITH CostPerGame AS (
	SELECT 
		salaries.yearid, 
		people.namegiven AS player_name,
		SUM(salaries.salary) AS total_salary,
		SUM(pitching.gs) AS total_games_started,
		(SUM(salaries.salary) / NULLIF(SUM(pitching.gs), 0)) AS cost_per_game_started,
		ROW_NUMBER() OVER (PARTITION BY salaries.yearid ORDER BY (SUM(salaries.salary) / NULLIF(SUM(pitching.gs), 0)) DESC) AS rn
	FROM salaries
	JOIN pitching ON salaries.playerid = pitching.playerid 
		AND salaries.teamid = pitching.teamid 
		AND salaries.yearid = pitching.yearid
	JOIN people ON pitching.playerid = people.playerid
	WHERE pitching.gs >= 10
	GROUP BY salaries.yearid, people.namegiven, pitching.playerid
)
SELECT 
	yearid,
	player_name,
	total_salary,
	total_games_started,
	cost_per_game_started
FROM CostPerGame
WHERE rn = 1
ORDER BY yearid;

--Check halloffame table
SELECT * FROM halloffame LIMIT 15;
SELECT DISTINCT halloffame.category FROM halloffame;
--Distinct categories are Umpire, Manager, Player, Pioneer/Executive

--Suppose we want for each year, each category ,(from each team->TEAM WONT BE POSSIBLE SINCE THAT"S OBER THEIR ENTIRE CAREER) the player who had the most votes 
--Let's look at HallOfFame table, and people (to get player name)
WITH ranked_halloffame AS (
	SELECT halloffame.yearid,
		   halloffame.category,
		   people.namegiven AS name,
		   halloffame.votes,
		   ROW_NUMBER() OVER (PARTITION BY halloffame.yearid, halloffame.category ORDER BY halloffame.votes DESC) AS rn
	FROM halloffame 
		JOIN people ON halloffame.playerid = people.playerid			
)
SELECT 
	yearid,
	category,
	name,
	votes
FROM ranked_halloffame
WHERE rn = 1
ORDER BY yearid, category;
/*
In the provided query that uses the `WITH` clause (Common Table Expression or CTE) and the `ROW_NUMBER()` window function, the `GROUP BY` clause is not used because the window function is handling the grouping and ordering internally.

Here's the relevant part of the query:

```sql
WITH RankedHallOfFame AS (
    SELECT 
        h.yearid,
        h.category,
        p.namegiven AS name,
        h.votes,
        ROW_NUMBER() OVER (
            PARTITION BY h.yearid, h.category
            ORDER BY h.votes DESC
        ) AS rn
    FROM halloffame h
    JOIN people p ON h.playerid = p.playerid
)
```

### Window Functions vs. `GROUP BY`

1. **Window Functions (`ROW_NUMBER()` in this case)**:
   - They operate over a set of rows defined by the `OVER` clause (which we refer to as a window).
   - The `PARTITION BY` in the `OVER` clause effectively groups the data within the window but does not collapse the rows into a single row like `GROUP BY`. Instead, it allows each row to retain its identity and additional calculations or rankings.
   - The `ORDER BY` within the `OVER` clause is used to determine the sequence of the row numbers within each partition.

2. **`GROUP BY` Clause**:
   - It is used to group rows that have the same values in specified columns and collapses these rows into a single row to return aggregate values.
   - If you were to use `GROUP BY` here, you would typically be using aggregate functions like `SUM()`, `MAX()`, etc., and the result would include one row per group.

### Why `GROUP BY` is Not Needed Here

- The goal is not to aggregate data and get one row per group; instead, it's to assign a rank within each group while maintaining individual rows. This is something window functions do that `GROUP BY` cannot.
- The `ROW_NUMBER()` function is generating a unique row number for each row within each partition ordered by the number of votes in descending order. This effectively "ranks" the rows without collapsing them.
- The `rn = 1` filter in the outer query is then used to pick out the top-ranked row (the one with the most votes) for each year and category.

### Conclusion

In summary, the use of `ROW_NUMBER()` with `PARTITION BY` in this query replaces the need for `GROUP BY` because we're not trying to aggregate data. We're ranking individual rows within groups and then selecting the top-ranked rows. The `WITH` clause is just a way to define a CTE, which is a named temporary result set that we can then query as if it were a regular table.
*/