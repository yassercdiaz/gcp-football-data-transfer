-- Find clubs that don't match any league (data quality check)
-- Uses LEFT JOIN to find orphaned records

SELECT 
  c.club_name,
  c.domestic_competition_id,
  c.stadium_seats,
  c.squad_quality_score,
  c.transfer_strategy,
  
  -- League info (will be NULL if no match)
  l.league_name,
  l.country
  
FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c

LEFT JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
  ON c.domestic_competition_id = l.league_id

WHERE l.league_id IS NULL  -- Only clubs without a league match

ORDER BY c.squad_quality_score DESC NULLS LAST
LIMIT 50;