-- Summary facts table for dashboard overview
-- Materialized for instant loading

CREATE OR REPLACE TABLE `gcp-football-data-transfer.football_marts.summary_facts` AS

WITH global_stats AS (
  SELECT 
    'Global' as scope,
    'All Clubs' as scope_name,
    
    COUNT(*) as total_clubs,
    ROUND(AVG(squad_quality_score), 1) as avg_quality,
    ROUND(MIN(squad_quality_score), 1) as min_quality,
    ROUND(MAX(squad_quality_score), 1) as max_quality,
    ROUND(SUM(net_transfer_balance), 0) as total_transfers,
    ROUND(AVG(foreigners_percentage), 1) as avg_foreign_pct,
    ROUND(AVG(stadium_seats), 0) as avg_stadium
    
  FROM `gcp-football-data-transfer.football_marts.clubs_analytics`
  WHERE squad_quality_score IS NOT NULL
    AND net_transfer_balance IS NOT NULL
),

tier_stats AS (
  SELECT 
    'Tier' as scope,
    l.league_tier as scope_name,
    
    COUNT(*) as total_clubs,
    ROUND(AVG(c.squad_quality_score), 1) as avg_quality,
    ROUND(MIN(c.squad_quality_score), 1) as min_quality,
    ROUND(MAX(c.squad_quality_score), 1) as max_quality,
    ROUND(SUM(c.net_transfer_balance), 0) as total_transfers,
    ROUND(AVG(c.foreigners_percentage), 1) as avg_foreign_pct,
    ROUND(AVG(c.stadium_seats), 0) as avg_stadium
    
  FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c
  JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
    ON c.domestic_competition_id = l.league_id
  WHERE c.squad_quality_score IS NOT NULL
    AND c.net_transfer_balance IS NOT NULL
  GROUP BY l.league_tier
),

top_leagues AS (
  SELECT 
    'League' as scope,
    l.league_name as scope_name,
    
    COUNT(*) as total_clubs,
    ROUND(AVG(c.squad_quality_score), 1) as avg_quality,
    ROUND(MIN(c.squad_quality_score), 1) as min_quality,
    ROUND(MAX(c.squad_quality_score), 1) as max_quality,
    ROUND(SUM(c.net_transfer_balance), 0) as total_transfers,
    ROUND(AVG(c.foreigners_percentage), 1) as avg_foreign_pct,
    ROUND(AVG(c.stadium_seats), 0) as avg_stadium
    
  FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c
  JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
    ON c.domestic_competition_id = l.league_id
  WHERE c.squad_quality_score IS NOT NULL
    AND c.net_transfer_balance IS NOT NULL
    AND l.league_tier IN ('Top 5', 'Secondary')
  GROUP BY l.league_name
)

SELECT * FROM global_stats
UNION ALL
SELECT * FROM tier_stats
UNION ALL
SELECT * FROM top_leagues
ORDER BY 
  CASE scope
    WHEN 'Global' THEN 1
    WHEN 'Tier' THEN 2
    ELSE 3
  END,
  scope_name;