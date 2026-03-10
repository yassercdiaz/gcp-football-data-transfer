-- Data quality validation checks
-- Run these to ensure data integrity

-- Check 1: Null values in key fields
SELECT 
  'Null Check' as check_type,
  'club_name' as field_name,
  COUNT(*) as null_count
FROM `gcp-football-data-transfer.football_marts.clubs_analytics`
WHERE club_name IS NULL

UNION ALL

SELECT 
  'Null Check',
  'domestic_competition_id',
  COUNT(*)
FROM `gcp-football-data-transfer.football_marts.clubs_analytics`
WHERE domestic_competition_id IS NULL

UNION ALL

SELECT 
  'Null Check',
  'squad_quality_score',
  COUNT(*)
FROM `gcp-football-data-transfer.football_marts.clubs_analytics`
WHERE squad_quality_score IS NULL;

-- Check 2: Duplicate club names
WITH duplicates AS (
  SELECT 
    club_name,
    COUNT(*) as count
  FROM `gcp-football-data-transfer.football_marts.clubs_analytics`
  GROUP BY club_name
  HAVING COUNT(*) > 1
)
SELECT 
  'Duplicate Check' as check_type,
  club_name,
  count
FROM duplicates;

-- Check 3: Value ranges
SELECT 
  'Range Check' as check_type,
  'squad_quality_score' as field,
  MIN(squad_quality_score) as min_value,
  MAX(squad_quality_score) as max_value,
  AVG(squad_quality_score) as avg_value
FROM `gcp-football-data-transfer.football_marts.clubs_analytics`

UNION ALL

SELECT 
  'Range Check',
  'foreigners_percentage',
  MIN(foreigners_percentage),
  MAX(foreigners_percentage),
  AVG(foreigners_percentage)
FROM `gcp-football-data-transfer.football_marts.clubs_analytics`;

-- Check 4: League coverage
SELECT 
  'League Coverage' as check_type,
  l.league_name,
  COUNT(c.club_name) as club_count
FROM `gcp-football-data-transfer.football_dimensions.leagues` l
LEFT JOIN `gcp-football-data-transfer.football_marts.clubs_analytics` c
  ON l.league_id = c.domestic_competition_id
GROUP BY l.league_name
ORDER BY club_count DESC;