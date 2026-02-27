-- Compare Top 5 leagues vs Secondary leagues
-- Aggregates to see systemic differences

WITH tier_comparison AS (
  SELECT 
    l.league_tier,
    
    COUNT(DISTINCT l.league_id) as total_leagues,
    COUNT(*) as total_clubs,
    
    -- Stadium
    ROUND(AVG(c.stadium_seats), 0) as avg_stadium,
    
    -- Squad
    ROUND(AVG(c.average_age), 1) as avg_age,
    ROUND(AVG(c.foreigners_percentage), 1) as avg_foreign_pct,
    
    -- Financial
    ROUND(AVG(c.net_transfer_balance), 0) as avg_transfer_balance,
    ROUND(SUM(c.net_transfer_balance), 0) as total_transfer_balance,
    
    -- Quality
    ROUND(AVG(c.squad_quality_score), 1) as avg_quality,
    
    -- Strategy counts
    SUM(CASE WHEN c.transfer_strategy IN ('Major Seller', 'Net Seller') THEN 1 ELSE 0 END) as sellers,
    SUM(CASE WHEN c.transfer_strategy IN ('Major Buyer', 'Net Buyer') THEN 1 ELSE 0 END) as buyers
    
  FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c
  
  INNER JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
    ON c.domestic_competition_id = l.league_id
  
  WHERE c.net_transfer_balance IS NOT NULL
    AND l.league_tier IN ('Top 5', 'Secondary')
  
  GROUP BY l.league_tier
)

SELECT 
  league_tier,
  total_leagues,
  total_clubs,
  avg_stadium,
  avg_age,
  avg_foreign_pct,
  avg_transfer_balance,
  total_transfer_balance,
  avg_quality,
  sellers,
  buyers,
  ROUND((sellers / total_clubs) * 100, 1) as pct_sellers,
  ROUND((buyers / total_clubs) * 100, 1) as pct_buyers

FROM tier_comparison
ORDER BY 
  CASE league_tier
    WHEN 'Top 5' THEN 1
    ELSE 2
  END;