-- Divide clubs into quality tiers using NTILE
-- Creates quartiles globally and within each league

WITH club_tiers AS (
  SELECT 
    club_name,
    league_name,
    country,
    league_tier,
    squad_quality_score,
    net_transfer_balance,
    foreigners_percentage,
    stadium_seats,
    
    -- Global tiers (divide all clubs into 4 groups)
    NTILE(4) OVER (ORDER BY squad_quality_score DESC) as global_quartile,
    
    -- League-specific tiers (divide each league into 4 groups)
    NTILE(4) OVER (
      PARTITION BY league_name 
      ORDER BY squad_quality_score DESC
    ) as league_quartile,
    
    -- Deciles (divide into 10 groups for finer granularity)
    NTILE(10) OVER (ORDER BY squad_quality_score DESC) as global_decile
    
  FROM `gcp-football-data-transfer.football_marts.vw_clubs_enriched`
  WHERE squad_quality_score IS NOT NULL
)

SELECT 
  club_name,
  league_name,
  ROUND(squad_quality_score, 1) as quality,
  
  -- Global classification
  global_quartile,
  CASE global_quartile
    WHEN 1 THEN '⭐ Elite (Top 25%)'
    WHEN 2 THEN '🔵 Strong (25-50%)'
    WHEN 3 THEN '🟢 Average (50-75%)'
    WHEN 4 THEN '⚪ Developing (Bottom 25%)'
  END as global_tier_label,
  
  -- League classification
  league_quartile,
  CASE league_quartile
    WHEN 1 THEN 'League Leader'
    WHEN 2 THEN 'Upper Mid-Table'
    WHEN 3 THEN 'Lower Mid-Table'
    WHEN 4 THEN 'Relegation Zone'
  END as league_tier_label,
  
  global_decile,
  ROUND(net_transfer_balance, 0) as transfer_balance

FROM club_tiers
ORDER BY squad_quality_score DESC
LIMIT 50;