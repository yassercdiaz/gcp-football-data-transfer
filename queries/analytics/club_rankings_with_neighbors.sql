-- Club rankings with comparisons to previous/next clubs
-- Uses LAG and LEAD to show competitive context

WITH ranked_clubs AS (
  SELECT 
    club_name,
    league_name,
    country,
    squad_quality_score,
    net_transfer_balance,
    foreigners_percentage,
    
    -- Rankings
    ROW_NUMBER() OVER (ORDER BY squad_quality_score DESC) as global_rank,
    ROW_NUMBER() OVER (PARTITION BY league_name ORDER BY squad_quality_score DESC) as league_rank,
    
    -- Compare with neighbors (LAG = previous, LEAD = next)
    LAG(club_name) OVER (ORDER BY squad_quality_score DESC) as better_club,
    LAG(squad_quality_score) OVER (ORDER BY squad_quality_score DESC) as better_score,
    
    LEAD(club_name) OVER (ORDER BY squad_quality_score DESC) as worse_club,
    LEAD(squad_quality_score) OVER (ORDER BY squad_quality_score DESC) as worse_score,
    
    -- Gap analysis
    squad_quality_score - LAG(squad_quality_score) OVER (ORDER BY squad_quality_score DESC) as gap_to_above,
    LEAD(squad_quality_score) OVER (ORDER BY squad_quality_score DESC) - squad_quality_score as gap_to_below
    
  FROM `gcp-football-data-transfer.football_marts.vw_clubs_enriched`
  WHERE squad_quality_score IS NOT NULL
)

SELECT 
  global_rank,
  league_rank,
  club_name,
  league_name,
  ROUND(squad_quality_score, 1) as quality,
  
  -- Context
  better_club,
  ROUND(better_score, 1) as better_score,
  ROUND(gap_to_above, 1) as gap_above,
  
  worse_club,
  ROUND(worse_score, 1) as worse_score,
  ROUND(gap_to_below, 1) as gap_below
  
FROM ranked_clubs
WHERE global_rank <= 30  -- Top 30 clubs
ORDER BY global_rank;