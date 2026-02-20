-- Club rankings using window functions
-- Ranks clubs by multiple dimensions and calculates percentiles

SELECT 
  name,
  stadium_seats,
  squad_size,
  average_age,
  foreigners_percentage,
  national_team_players,
  
  -- Rankings
  ROW_NUMBER() OVER (ORDER BY stadium_seats DESC) as stadium_rank,
  ROW_NUMBER() OVER (ORDER BY squad_size DESC) as squad_size_rank,
  ROW_NUMBER() OVER (ORDER BY foreigners_percentage DESC) as international_rank,
  
  -- Percentiles
  PERCENT_RANK() OVER (ORDER BY stadium_seats) as stadium_percentile,
  PERCENT_RANK() OVER (ORDER BY foreigners_percentage) as international_percentile,
  
  -- Running totals
  SUM(squad_size) OVER (ORDER BY stadium_seats DESC) as cumulative_players

FROM `gcp-football-data-transfer.football_transfer_raw.clubs`
WHERE stadium_seats IS NOT NULL 
  AND squad_size IS NOT NULL
  AND foreigners_percentage IS NOT NULL
ORDER BY stadium_seats DESC
LIMIT 50;