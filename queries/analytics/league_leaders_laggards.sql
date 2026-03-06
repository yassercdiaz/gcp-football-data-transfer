-- Identify best and worst clubs in each league
-- Uses FIRST_VALUE and LAST_VALUE window functions

WITH league_extremes AS (
  SELECT 
    club_name,
    league_name,
    country,
    squad_quality_score,
    net_transfer_balance,
    foreigners_percentage,
    
    -- Best club in league (highest quality)
    FIRST_VALUE(club_name) OVER (
      PARTITION BY league_name 
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as league_best_club,
    
    FIRST_VALUE(squad_quality_score) OVER (
      PARTITION BY league_name 
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as league_best_quality,
    
    -- Worst club in league (lowest quality)
    LAST_VALUE(club_name) OVER (
      PARTITION BY league_name 
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as league_worst_club,
    
    LAST_VALUE(squad_quality_score) OVER (
      PARTITION BY league_name 
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as league_worst_quality,
    
    -- Club's position relative to best/worst
    squad_quality_score - FIRST_VALUE(squad_quality_score) OVER (
      PARTITION BY league_name 
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as gap_from_best,
    
    squad_quality_score - LAST_VALUE(squad_quality_score) OVER (
      PARTITION BY league_name 
      ORDER BY squad_quality_score DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as gap_from_worst
    
  FROM `gcp-football-data-transfer.football_marts.vw_clubs_enriched`
  WHERE squad_quality_score IS NOT NULL
)

SELECT 
  league_name,
  club_name,
  ROUND(squad_quality_score, 1) as quality,
  
  -- League context
  league_best_club,
  ROUND(league_best_quality, 1) as best_quality,
  ROUND(gap_from_best, 1) as gap_from_best,
  
  league_worst_club,
  ROUND(league_worst_quality, 1) as worst_quality,
  ROUND(gap_from_worst, 1) as gap_from_worst,
  
  -- Relative position
  ROUND(
    (gap_from_worst / (league_best_quality - league_worst_quality)) * 100, 
    1
  ) as pct_of_league_range

FROM league_extremes
ORDER BY league_name, squad_quality_score DESC;