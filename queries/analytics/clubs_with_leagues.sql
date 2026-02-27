-- Join clubs with their leagues
-- Demonstrates INNER JOIN and enriches club data with league context

SELECT 
  c.club_name,
  c.stadium_name,
  c.stadium_seats,
  c.average_age,
  c.foreigners_percentage,
  c.net_transfer_balance,
  c.transfer_strategy,
  c.squad_quality_score,
  
  -- League information
  l.league_name,
  l.country,
  l.league_tier
  
FROM `gcp-football-data-transfer.football_staging.stg_clubs` c

INNER JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
  ON c.domestic_competition_id = l.league_id
  
WHERE c.stadium_seats IS NOT NULL

ORDER BY c.stadium_seats DESC
LIMIT 20;