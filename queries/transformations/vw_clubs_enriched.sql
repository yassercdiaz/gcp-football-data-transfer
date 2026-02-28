-- Enriched clubs view for dashboards and visualization
-- Combines clubs, leagues, and calculated metrics in a single denormalized view

CREATE OR REPLACE VIEW `gcp-football-data-transfer.football_marts.vw_clubs_enriched` AS

SELECT 
  -- Identifiers
  c.club_id,
  c.club_name,
  c.domestic_competition_id,
  
  -- League context
  l.league_name,
  l.country,
  l.league_tier,
  
  -- Stadium
  c.stadium_name,
  c.stadium_seats,
  c.stadium_size_category,
  c.seats_per_player,
  
  -- Squad basics
  c.squad_size,
  c.average_age,
  c.age_category,
  
  -- Internationalization
  c.foreigners_number,
  c.foreigners_percentage,
  c.internationalization_level,
  c.national_team_players,
  c.national_team_percentage,
  
  -- Coaching
  -- c.coach_name,
  
  -- Financial
  c.net_transfer_balance,
  c.transfer_balance_per_player,
  c.transfer_strategy,
  
  -- Quality & Rankings
  c.squad_quality_score,
  c.stadium_rank,
  c.internationalization_rank,
  c.net_seller_rank,
  c.quality_rank,
  
  -- Flags for filtering
  c.is_large_stadium,
  c.is_highly_international,
  c.is_net_seller,
  c.is_net_buyer,
  c.has_many_nationals,
  
  -- League aggregates (for context)
  AVG(c.squad_quality_score) OVER (PARTITION BY l.league_name) as league_avg_quality,
  AVG(c.foreigners_percentage) OVER (PARTITION BY l.league_name) as league_avg_foreign_pct,
  AVG(c.net_transfer_balance) OVER (PARTITION BY l.league_name) as league_avg_transfer_balance,
  
  -- Tier aggregates
  AVG(c.squad_quality_score) OVER (PARTITION BY l.league_tier) as tier_avg_quality,
  AVG(c.foreigners_percentage) OVER (PARTITION BY l.league_tier) as tier_avg_foreign_pct

FROM `gcp-football-data-transfer.football_marts.clubs_analytics` c

INNER JOIN `gcp-football-data-transfer.football_dimensions.leagues` l
  ON c.domestic_competition_id = l.league_id

WHERE c.stadium_seats IS NOT NULL;