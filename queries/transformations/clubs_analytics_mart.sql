-- Analytical mart: Aggregated club insights
-- Materializes key metrics for dashboard consumption
-- Updates: Manual (can be scheduled in production)

CREATE OR REPLACE TABLE `gcp-football-data-transfer.football_marts.clubs_analytics` AS

WITH club_metrics AS (
  SELECT
    domestic_competition_id,
    club_id, 
    club_name,
    stadium_name,
    stadium_seats,
    squad_size,
    average_age,
    age_category,
    foreigners_number,
    foreigners_percentage,
    internationalization_level,
    national_team_players,
    net_transfer_balance,
    transfer_strategy,
    stadium_size_category,
    seats_per_player,
    
    -- Financial metrics
    CASE 
      WHEN squad_size > 0 AND net_transfer_balance IS NOT NULL
      THEN ROUND(net_transfer_balance / squad_size, 0)
      ELSE NULL
    END as transfer_balance_per_player,
    
    -- Performance indicators
    CASE 
      WHEN squad_size > 0 AND national_team_players IS NOT NULL
      THEN ROUND((national_team_players / squad_size) * 100, 1)
      ELSE NULL
    END as national_team_percentage,
    
    -- Squad efficiency score (0-100)
    ROUND(
      (COALESCE(foreigners_percentage, 0) * 0.3) +
      (COALESCE(national_team_players, 0) * 5) +
      (CASE WHEN average_age BETWEEN 24 AND 28 THEN 20 ELSE 0 END)
    , 1) as squad_quality_score
    
  FROM `gcp-football-data-transfer.football_staging.stg_clubs`
)

SELECT 
  *,
  
  -- Rankings within categories
  ROW_NUMBER() OVER (ORDER BY stadium_seats DESC) as stadium_rank,
  ROW_NUMBER() OVER (ORDER BY foreigners_percentage DESC) as internationalization_rank,
  ROW_NUMBER() OVER (ORDER BY net_transfer_balance DESC) as net_seller_rank,
  ROW_NUMBER() OVER (ORDER BY squad_quality_score DESC) as quality_rank,
  
  -- Percentiles
  PERCENT_RANK() OVER (ORDER BY stadium_seats) as stadium_percentile,
  PERCENT_RANK() OVER (ORDER BY foreigners_percentage) as international_percentile,
  
  -- Categorization flags
  CASE WHEN stadium_seats >= 60000 THEN TRUE ELSE FALSE END as is_large_stadium,
  CASE WHEN foreigners_percentage >= 75 THEN TRUE ELSE FALSE END as is_highly_international,
  CASE WHEN net_transfer_balance > 10000000 THEN TRUE ELSE FALSE END as is_net_seller,
  CASE WHEN net_transfer_balance < -10000000 THEN TRUE ELSE FALSE END as is_net_buyer,
  CASE WHEN national_team_players >= 10 THEN TRUE ELSE FALSE END as has_many_nationals

FROM club_metrics
ORDER BY stadium_seats DESC;