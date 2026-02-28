-- Financial flow between league tiers
-- Shows how money moves from Secondary → Top 5

SELECT 
  l.league_tier,
  l.league_name,
  
  -- Money metrics
  ROUND(SUM(c.net_transfer_balance), 0) as total_balance,
  ROUND(AVG(c.net_transfer_balance), 0) as avg_balance_per_club,
  
  -- Direction
  CASE 
    WHEN SUM(c.net_transfer_balance) > 10000000 THEN '💰 Net Exporter'
    WHEN SUM(c.net_transfer_balance) < -10000000 THEN '💸 Net Importer'
    ELSE '⚖️ Balanced'
  END as financial_role,
  
  COUNT(*) as clubs_analyzed

FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c

INNER JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
  ON c.domestic_competition_id = l.league_id

WHERE c.net_transfer_balance IS NOT NULL

GROUP BY l.league_tier, l.league_name

ORDER BY total_balance DESC;