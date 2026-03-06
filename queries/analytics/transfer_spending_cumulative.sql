-- Running totals of transfer spending by league
-- Shows cumulative financial commitment ordered by club quality

WITH league_spending AS (
  SELECT 
    club_name,
    league_name,
    squad_quality_score,
    net_transfer_balance,
    
    -- Running total of transfer balance (ordered by quality)
    SUM(net_transfer_balance) OVER (
      PARTITION BY league_name
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_transfer_balance,
    
    -- Count of clubs accumulated so far
    ROW_NUMBER() OVER (
      PARTITION BY league_name
      ORDER BY squad_quality_score DESC
    ) as clubs_counted,
    
    -- Moving average of last 3 clubs
    AVG(net_transfer_balance) OVER (
      PARTITION BY league_name
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_3_clubs,
    
    -- Percentage of league total
    net_transfer_balance / SUM(net_transfer_balance) OVER (PARTITION BY league_name) as pct_of_league_total
    
  FROM `gcp-football-data-transfer.football_marts.vw_clubs_enriched`
  WHERE net_transfer_balance IS NOT NULL
    AND squad_quality_score IS NOT NULL
)

SELECT 
  league_name,
  club_name,
  ROUND(squad_quality_score, 1) as quality,
  ROUND(net_transfer_balance, 0) as transfer_balance,
  ROUND(cumulative_transfer_balance, 0) as cumulative_balance,
  clubs_counted,
  ROUND(moving_avg_3_clubs, 0) as moving_avg_3,
  ROUND(pct_of_league_total * 100, 1) as pct_of_total

FROM league_spending
WHERE league_name IN ('Premier League', 'La Liga', 'Bundesliga', 'Serie A', 'Ligue 1')
ORDER BY league_name, squad_quality_score DESC;