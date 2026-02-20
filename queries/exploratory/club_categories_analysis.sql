-- Comprehensive club analysis with multiple metrics and categories
-- Groups clubs by age and internationalization to find patterns

WITH club_metrics AS (
  SELECT 
    name,
    stadium_name,
    stadium_seats,
    squad_size,
    average_age,
    foreigners_percentage,
    national_team_players,
    
    -- Age category
    CASE 
      WHEN average_age < 24 THEN 'Very Young'
      WHEN average_age BETWEEN 24 AND 26 THEN 'Young'
      WHEN average_age BETWEEN 26 AND 28 THEN 'Mature'
      ELSE 'Veteran'
    END as age_category,
    
    -- Internationalization level
    CASE 
      WHEN foreigners_percentage >= 75 THEN 'Highly International'
      WHEN foreigners_percentage >= 50 THEN 'International'
      WHEN foreigners_percentage >= 25 THEN 'Mixed'
      ELSE 'Mostly Domestic'
    END as international_level,
    
    -- Stadium size category
    CASE 
      WHEN stadium_seats >= 60000 THEN 'Large'
      WHEN stadium_seats >= 30000 THEN 'Medium'
      WHEN stadium_seats >= 15000 THEN 'Small'
      ELSE 'Very Small'
    END as stadium_category
    
  FROM `gcp-football-data-transfer.football_transfer_raw.clubs`
  WHERE average_age IS NOT NULL 
    AND foreigners_percentage IS NOT NULL
    AND stadium_seats IS NOT NULL
)

SELECT 
  age_category,
  international_level,
  stadium_category,
  COUNT(*) as club_count,
  ROUND(AVG(squad_size), 1) as avg_squad_size,
  ROUND(AVG(average_age), 1) as avg_age,
  ROUND(AVG(foreigners_percentage), 1) as avg_foreign_pct,
  ROUND(AVG(national_team_players), 1) as avg_national_players
FROM club_metrics
GROUP BY age_category, international_level, stadium_category
HAVING club_count >= 2  -- Only show combinations with 2+ clubs
ORDER BY club_count DESC, avg_foreign_pct DESC
LIMIT 20;