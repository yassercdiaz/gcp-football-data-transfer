-- League summary view for dashboard KPIs
-- Pre-aggregated metrics for fast loading

CREATE OR REPLACE VIEW `gcp-football-data-transfer.football_marts.vw_league_summary` AS

SELECT 
  l.league_name,
  l.country,
  l.league_tier,
  
  -- Club counts
  COUNT(DISTINCT c.club_name) as total_clubs,
  
  -- Quality metrics
  ROUND(MIN(c.squad_quality_score), 1) as min_quality,
  ROUND(MAX(c.squad_quality_score), 1) as max_quality,
  ROUND(AVG(c.squad_quality_score), 1) as avg_quality,
  ROUND(MAX(c.squad_quality_score) - MIN(c.squad_quality_score), 1) as quality_range,
  ROUND(STDDEV(c.squad_quality_score), 1) as stddev_quality,
  
  -- Stadium metrics
  ROUND(AVG(c.stadium_seats), 0) as avg_stadium_capacity,
  SUM(c.stadium_seats) as total_stadium_capacity,
  
  -- Squad metrics
  ROUND(AVG(c.squad_size), 1) as avg_squad_size,
  ROUND(AVG(c.average_age), 1) as avg_age,
  
  -- Internationalization
  ROUND(AVG(c.foreigners_percentage), 1) as avg_foreign_pct,
  ROUND(AVG(c.national_team_players), 1) as avg_national_players,
  
  -- Financial metrics
  ROUND(SUM(c.net_transfer_balance), 0) as total_transfer_balance,
  ROUND(AVG(c.net_transfer_balance), 0) as avg_transfer_balance,
  
  -- Transfer strategy counts
  SUM(CASE WHEN c.is_net_seller THEN 1 ELSE 0 END) as net_sellers_count,
  SUM(CASE WHEN c.is_net_buyer THEN 1 ELSE 0 END) as net_buyers_count,
  
  -- Percentages
  ROUND(SUM(CASE WHEN c.is_net_seller THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as pct_sellers,
  ROUND(SUM(CASE WHEN c.is_net_buyer THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as pct_buyers,
  
  -- Competitive balance
  ROUND(STDDEV(c.squad_quality_score) / AVG(c.squad_quality_score) * 100, 1) as coefficient_of_variation,
  
  CASE 
    WHEN MAX(c.squad_quality_score) - MIN(c.squad_quality_score) > 100 THEN 'Very Unbalanced'
    WHEN MAX(c.squad_quality_score) - MIN(c.squad_quality_score) > 60 THEN 'Unbalanced'
    WHEN MAX(c.squad_quality_score) - MIN(c.squad_quality_score) > 30 THEN 'Moderately Balanced'
    ELSE 'Well Balanced'
  END as balance_rating

FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c

INNER JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
  ON c.domestic_competition_id = l.league_id

WHERE c.squad_quality_score IS NOT NULL
  AND c.net_transfer_balance IS NOT NULL

GROUP BY l.league_name, l.country, l.league_tier;