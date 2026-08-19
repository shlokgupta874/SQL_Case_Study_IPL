--Q1 Find the total spending on players for each team:

SELECT Team, SUM(price_in_cr) AS 'Total Spending'
FROM IPLPlayers
GROUP BY Team
Order BY 'Total Spending' DESC

--Q2 Find the top 3 highest paid 'All-rounders' across all team:

SELECT Player, Team, Price_in_cr
FROM IPLPlayers
WHERE Role = 'All-rounder'
Order By Price_in_cr DESC

--Q3 Find the highest-priced player in each team:

SELECT *
FROM IPLPlayers
ORDER BY Price_in_cr DESC
;
WITH CTE_MP AS(
	SELECT TEAM,Max(Price_in_cr) AS MaxPrice
	FROM IPLPlayers
	GROUP BY Team
)
SELECT i.Team, i.Player, c.MaxPrice
FROM IPLPlayers i
JOIN CTE_MP c ON i.Team = c.Team
WHERE i.Price_in_cr = c.MaxPrice


--Q4 Rank players by their price within each team and list the top 2 for every team:

SELECT *
FROM IPLPlayers
ORDER BY Team
;
With RankedPlayers AS(
SELECT Player, Team, Price_in_cr,
ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
FROM IPLPlayers
)
SELECT Player, Team, Price_in_cr,RankWithinTeam
FROM RankedPlayers
WHERE RankWithinTeam <= 2
;

--Q5 find the most expensive player from each team, along with the second-most expensive player's name and price:

With RankedPlayers AS(
	SELECT Player, Team, Price_in_cr,
	ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
	FROM IPLPlayers
)
SELECT Team, 
	MAX(CASE WHEN RankWithinTeam = 1 THEN Player END) AS MostExpensivePlayer,
	MAX(CASE WHEN RankWithinTeam = 1 THEN Price_in_cr END) AS HighestPrice,
	MAX(CASE WHEN RankWithinTeam = 2 THEN Player END) AS SecondMostExpensivePlayer,
	MAX(CASE WHEN RankWithinTeam = 2 THEN Price_in_cr END) AS SecondHighestPrice
FROM RankedPlayers
GROUP BY Team

--Q6 Calculate the percentage contribution of each player's price to their team's total spending

SELECT Player, Team, Price_in_cr,
	CAST(Price_in_cr/ (SUM(Price_in_cr) OVER (PARTITION BY Team)) * 100 AS DECIMAL(10,2)) AS ContributionPercentage
FROM IPLPlayers

--Q7 Classify players as 'High', 'Medium', or 'Low' priced based on the following rules:
--High: Price > ₹15 crore
--Medium: Price between ₹5 crore and ₹15 crore
--Low: Price < ₹5 crore
--and find out the number of players in  each bracket
;
WITH CTE_BR AS(
	SELECT Team, Player, Price_in_cr,
		CASE 
			WHEN Price_in_cr > 15 THEN 'High'
			WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'MEDIUM'
			ELSE 'Low'
		END AS PriceCategory
	FROM IPLPlayers
)
SELECT Team, PriceCategory, COUNT(*) AS 'NoofPlayers'
FROM CTE_BR
GROUP BY Team,PriceCategory
ORDER BY Team,PriceCategory

--Q8 Find the average price of Indian players and compare it with overseas players using a subquery:

SELECT * FROM IPLPlayers

SELECT
	'Indian' AS PlayerType,
	(SELECT AVG(Price_in_cr) 
	FROM IPLPlayers
	WHERE Type LIKE 'Indian%') AS AvgPrice
UNION ALL
SELECT
	'Overseas' AS PlayerType,
		(SELECT AVG(Price_in_cr) 
		FROM IPLPlayers
		WHERE Type LIKE 'Overseas%') AS AvgPrice


--Q9 Identify players who earn more than the average price of their team:
SELECT * 
FROM IPLPlayers

SELECT Player, Team, Price_in_cr
FROM IPLPlayers p
WHERE Price_in_cr > (
		SELECT AVG(Price_In_cr)
		FROM IPLPlayers
		WHERE Team = p.Team)

--Q10 For each role, find the most expensive player and their price using a correlated subquery

SELECT * 
FROM IPLPlayers

SELECT Player, Team, Role, Price_in_cr
FROM IPLPlayers p
WHERE Price_in_cr = (
		SELECT MAX(Price_in_cr)
		FROM IPLPlayers
		WHERE Role = p.Role
		)