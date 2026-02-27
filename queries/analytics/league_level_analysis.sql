-- Comprehensive league-level analysis
WITH league_stats AS (
  SELECT 
    l.league_name,
    l.country,
    l.league_tier,
    
    -- Club counts
    COUNT(*) as total_clubs,
    
    -- Stadium metrics
    ROUND(AVG(c.stadium_seats), 0) as avg_stadium_capacity,
    MAX(c.stadium_seats) as largest_stadium,
    
    -- Squad metrics
    ROUND(AVG(c.squad_size), 1) as avg_squad_size,
    ROUND(AVG(c.average_age), 1) as avg_age,
    
    -- Internationalization
    ROUND(AVG(c.foreigners_percentage), 1) as avg_foreign_pct,
    ROUND(AVG(c.national_team_players), 1) as avg_national_players,
    
    -- Financial metrics
    ROUND(AVG(c.net_transfer_balance), 0) as avg_transfer_balance,
    ROUND(SUM(c.net_transfer_balance), 0) as total_transfer_balance,
    
    -- Quality
    ROUND(AVG(c.squad_quality_score), 1) as avg_quality_score,
    
    -- Transfer strategy distribution
    SUM(CASE WHEN c.net_transfer_balance > 10000000 THEN 1 ELSE 0 END) as net_sellers,
    SUM(CASE WHEN c.net_transfer_balance < -10000000 THEN 1 ELSE 0 END) as net_buyers,
    SUM(CASE WHEN ABS(c.net_transfer_balance) <= 10000000 THEN 1 ELSE 0 END) as balanced
    
  FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c
  
  INNER JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
    ON c.domestic_competition_id = l.league_id
  
  WHERE c.net_transfer_balance IS NOT NULL
    AND c.stadium_seats IS NOT NULL
  
  GROUP BY l.league_name, l.country, l.league_tier
)

SELECT 
  league_name,
  country,
  league_tier,
  total_clubs,
  avg_stadium_capacity,
  largest_stadium,
  avg_age,
  avg_foreign_pct,
  avg_transfer_balance,
  total_transfer_balance,
  avg_quality_score,
  
  -- Transfer strategy breakdown
  net_sellers,
  net_buyers,
  balanced,
  
  -- Percentages
  ROUND((net_sellers / total_clubs) * 100, 1) as pct_sellers,
  ROUND((net_buyers / total_clubs) * 100, 1) as pct_buyers
  
FROM league_stats
ORDER BY 
  CASE league_tier
    WHEN 'Top 5' THEN 1
    WHEN 'Secondary' THEN 2
    ELSE 3
  END,
  avg_quality_score DESC;