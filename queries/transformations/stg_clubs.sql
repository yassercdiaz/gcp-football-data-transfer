-- Staging view: Clean and standardize raw club data
-- This view serves as the foundation for all analytical queries
-- Handles data type conversions, NULL values, and text parsing

CREATE OR REPLACE VIEW `gcp-football-data-transfer.football_staging.stg_clubs` AS

SELECT 
  -- Primary identifiers
  club_id,
  TRIM(name) as club_name,
  club_code,
  
  -- Stadium information
  TRIM(stadium_name) as stadium_name,
  stadium_seats,
  
  -- Squad metrics
  squad_size,
  ROUND(average_age, 1) as average_age,
  
  -- Internationalization metrics
  foreigners_number,
  ROUND(foreigners_percentage, 1) as foreigners_percentage,
  national_team_players,
  
  -- Coaching
  TRIM(coach_name) as coach_name,
  
  -- Transfer balance (cleaned and converted to numeric)
  CASE
    WHEN REGEXP_CONTAINS(net_transfer_record, r'm$') THEN
      SAFE_CAST(
        REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'm$', '') 
        AS FLOAT64
      ) * 1000000
    WHEN REGEXP_CONTAINS(net_transfer_record, r'k$') THEN
      SAFE_CAST(
        REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'k$', '') 
        AS FLOAT64
      ) * 1000
    WHEN net_transfer_record = '+-0' THEN 0.0
    ELSE NULL
  END as net_transfer_balance,
  
  -- Calculated fields
  CASE 
    WHEN squad_size > 0 AND stadium_seats IS NOT NULL 
    THEN ROUND(stadium_seats / squad_size, 0)
    ELSE NULL
  END as seats_per_player,
  
  -- Age category
  CASE 
    WHEN average_age IS NULL THEN 'Unknown'
    WHEN average_age < 24 THEN 'Very Young'
    WHEN average_age BETWEEN 24 AND 26 THEN 'Young'
    WHEN average_age BETWEEN 26 AND 28 THEN 'Mature'
    ELSE 'Veteran'
  END as age_category,
  
  -- Internationalization level
  CASE 
    WHEN foreigners_percentage IS NULL THEN 'Unknown'
    WHEN foreigners_percentage >= 75 THEN 'Highly International'
    WHEN foreigners_percentage >= 50 THEN 'International'
    WHEN foreigners_percentage >= 25 THEN 'Mixed'
    ELSE 'Mostly Domestic'
  END as internationalization_level,
  
  -- Stadium size category
  CASE 
    WHEN stadium_seats IS NULL THEN 'Unknown'
    WHEN stadium_seats >= 60000 THEN 'Large'
    WHEN stadium_seats >= 30000 THEN 'Medium'
    WHEN stadium_seats >= 15000 THEN 'Small'
    ELSE 'Very Small'
  END as stadium_size_category,
  
  -- Transfer strategy
  CASE
    WHEN net_transfer_record IS NULL OR net_transfer_record = '+-0' THEN 'Unknown'
    WHEN REGEXP_CONTAINS(net_transfer_record, r'm$') THEN
      CASE
        WHEN SAFE_CAST(REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'm$', '') AS FLOAT64) > 50 THEN 'Major Seller'
        WHEN SAFE_CAST(REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'm$', '') AS FLOAT64) > 10 THEN 'Net Seller'
        WHEN SAFE_CAST(REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'm$', '') AS FLOAT64) > 0 THEN 'Minor Seller'
        WHEN SAFE_CAST(REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'm$', '') AS FLOAT64) > -10 THEN 'Minor Buyer'
        WHEN SAFE_CAST(REGEXP_REPLACE(REGEXP_REPLACE(net_transfer_record, r'[+€]', ''), r'm$', '') AS FLOAT64) > -50 THEN 'Net Buyer'
        ELSE 'Major Buyer'
      END
    ELSE 'Balanced'
  END as transfer_strategy,
  
  -- Metadata
  last_season,
  url

FROM `gcp-football-data-transfer.football_transfer_raw.clubs`
WHERE name IS NOT NULL;  -- Exclude rows with no club name