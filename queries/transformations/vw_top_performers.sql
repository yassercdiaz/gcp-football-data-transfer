-- Top performing clubs globally and by league
-- Pre-ranked for dashboard consumption

CREATE OR REPLACE VIEW `gcp-football-data-transfer.football_marts.vw_top_performers` AS

SELECT 
  c.club_name,
  c.league_name,
  c.country,
  c.league_tier,
  
  -- Core metrics
  ROUND(c.squad_quality_score, 1) as quality_score,
  c.stadium_seats,
  c.squad_size,
  ROUND(c.average_age, 1) as average_age,
  ROUND(c.foreigners_percentage, 1) as foreigners_pct,
  c.national_team_players,
  ROUND(c.net_transfer_balance, 0) as transfer_balance,
  
  -- Categories
  c.age_category,
  c.internationalization_level,
  c.transfer_strategy,
  c.stadium_size_category,
  
  -- Rankings
  ROW_NUMBER() OVER (ORDER BY c.squad_quality_score DESC) as global_rank,
  ROW_NUMBER() OVER (PARTITION BY c.league_name ORDER BY c.squad_quality_score DESC) as league_rank,
  ROW_NUMBER() OVER (PARTITION BY c.league_tier ORDER BY c.squad_quality_score DESC) as tier_rank,
  
  -- Percentiles
  ROUND(PERCENT_RANK() OVER (ORDER BY c.squad_quality_score) * 100, 1) as global_percentile,
  ROUND(PERCENT_RANK() OVER (PARTITION BY c.league_name ORDER BY c.squad_quality_score) * 100, 1) as league_percentile,
  
  -- League context
  c.league_avg_quality,
  ROUND(c.squad_quality_score - c.league_avg_quality, 1) as quality_vs_league_avg,
  
  -- Tier context
  c.tier_avg_quality,
  ROUND(c.squad_quality_score - c.tier_avg_quality, 1) as quality_vs_tier_avg,
  
  -- Flags for easy filtering
  c.is_large_stadium,
  c.is_highly_international,
  c.is_net_seller,
  c.is_net_buyer,
  c.has_many_nationals,
  
  -- Tier labels
  CASE 
    WHEN ROW_NUMBER() OVER (ORDER BY c.squad_quality_score DESC) <= 10 THEN 'Global Top 10'
    WHEN ROW_NUMBER() OVER (ORDER BY c.squad_quality_score DESC) <= 50 THEN 'Global Top 50'
    WHEN PERCENT_RANK() OVER (ORDER BY c.squad_quality_score) >= 0.75 THEN 'Top Quartile'
    WHEN PERCENT_RANK() OVER (ORDER BY c.squad_quality_score) >= 0.50 THEN 'Upper Half'
    WHEN PERCENT_RANK() OVER (ORDER BY c.squad_quality_score) >= 0.25 THEN 'Lower Half'
    ELSE 'Bottom Quartile'
  END as global_tier_label

FROM `gcp-football-data-transfer.football_marts.vw_clubs_enriched` c

WHERE c.squad_quality_score IS NOT NULL;