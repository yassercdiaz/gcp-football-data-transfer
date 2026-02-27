-- Create leagues dimension table
-- Maps domestic_competition_id to league names and countries

CREATE OR REPLACE TABLE `gcp-football-data-transfer.football_dimensions.leagues` AS

WITH league_mappings AS (
  SELECT DISTINCT
    domestic_competition_id,
    
    -- Infer league name from common patterns
    CASE 
      -- Top 5 European Leagues
      WHEN domestic_competition_id = 'GB1' THEN 'Premier League'
      WHEN domestic_competition_id = 'ES1' THEN 'La Liga'
      WHEN domestic_competition_id = 'IT1' THEN 'Serie A'
      WHEN domestic_competition_id = 'L1' THEN 'Bundesliga'
      WHEN domestic_competition_id = 'FR1' THEN 'Ligue 1'
      
      -- Other Major Leagues
      WHEN domestic_competition_id = 'PO1' THEN 'Primeira Liga'
      WHEN domestic_competition_id = 'NL1' THEN 'Eredivisie'
      WHEN domestic_competition_id = 'BE1' THEN 'Pro League'
      WHEN domestic_competition_id = 'TR1' THEN 'Süper Lig'
      WHEN domestic_competition_id = 'RU1' THEN 'Premier Liga'
      WHEN domestic_competition_id = 'SC1' THEN 'Scottish Premiership'
      
      -- Default
      ELSE CONCAT('League_', domestic_competition_id)
    END as league_name,
    
    -- Infer country from competition ID
    CASE 
      WHEN domestic_competition_id = 'GB1' THEN 'England'
      WHEN domestic_competition_id = 'ES1' THEN 'Spain'
      WHEN domestic_competition_id = 'IT1' THEN 'Italy'
      WHEN domestic_competition_id = 'L1' THEN 'Germany'
      WHEN domestic_competition_id = 'FR1' THEN 'France'
      WHEN domestic_competition_id = 'PO1' THEN 'Portugal'
      WHEN domestic_competition_id = 'NL1' THEN 'Netherlands'
      WHEN domestic_competition_id = 'BE1' THEN 'Belgium'
      WHEN domestic_competition_id = 'TR1' THEN 'Turkey'
      WHEN domestic_competition_id = 'RU1' THEN 'Russia'
      WHEN domestic_competition_id = 'SC1' THEN 'Scotland'
      ELSE 'Other'
    END as country,
    
    -- League tier/reputation
    CASE 
      WHEN domestic_competition_id IN ('GB1', 'ES1', 'IT1', 'L1', 'FR1') THEN 'Top 5'
      WHEN domestic_competition_id IN ('PO1', 'NL1', 'BE1', 'TR1', 'RU1', 'SC1') THEN 'Secondary'
      ELSE 'Other'
    END as league_tier
    
  FROM `gcp-football-data-transfer.football_transfer_raw.clubs`
  WHERE domestic_competition_id IS NOT NULL
)

SELECT 
  domestic_competition_id as league_id,
  league_name,
  country,
  league_tier,
  
  -- Add metadata
  CURRENT_TIMESTAMP() as created_at
  
FROM league_mappings
ORDER BY 
  CASE league_tier
    WHEN 'Top 5' THEN 1
    WHEN 'Secondary' THEN 2
    ELSE 3
  END,
  league_name;