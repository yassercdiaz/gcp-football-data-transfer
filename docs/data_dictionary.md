# Data Dictionary

## Overview
This document describes all tables, views, and columns in the GCP Football Data Transfer project.

---

## Tables

### football_transfer_raw.clubs
**Purpose:** Raw data from Kaggle, unmodified

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| club_id | STRING | Unique identifier | "1" |
| name | STRING | Full club name | "Real Madrid Club de Fútbol" |
| domestic_competition_id | STRING | League identifier code | "ES1" |
| total_market_value | STRING | Total squad value (empty in dataset) | NULL |
| squad_size | INT64 | Number of players | 25 |
| average_age | FLOAT64 | Average age of squad | 26.3 |
| foreigners_number | INT64 | Count of foreign players | 17 |
| foreigners_percentage | FLOAT64 | Percentage of foreigners | 68.0 |
| national_team_players | INT64 | Players in national teams | 15 |
| stadium_name | STRING | Stadium name | "Santiago Bernabéu" |
| stadium_seats | INT64 | Stadium capacity | 83186 |
| net_transfer_record | STRING | Transfer balance (text format) | "-€165.5m" |
| coach_name | STRING | Head coach name | Various |
| last_season | STRING | Season of data | "2023" |

---

### football_dimensions.leagues
**Purpose:** Dimension table mapping league IDs to names and countries

| Column | Type | Description | Values |
|--------|------|-------------|--------|
| league_id | STRING | Competition ID (FK to clubs) | "ES1", "GB1", "IT1" |
| league_name | STRING | Display name | "La Liga", "Premier League" |
| country | STRING | Country | "Spain", "England" |
| league_tier | STRING | Classification | "Top 5", "Secondary", "Other" |
| created_at | TIMESTAMP | Metadata | Auto-generated |

---

### football_staging.stg_clubs (VIEW)
**Purpose:** Cleaned and standardized club data

**Transformations applied:**
- TRIM() on text fields
- ROUND() on numeric fields
- CASE statements for categorization
- REGEX cleaning of net_transfer_record
- NULL handling with 'Unknown' labels

**Key calculated fields:**

| Column | Calculation | Description |
|--------|-------------|-------------|
| net_transfer_balance | REGEX + CAST | Text → numeric euros |
| seats_per_player | stadium_seats / squad_size | Capacity efficiency |
| age_category | CASE on average_age | "Very Young", "Young", "Mature", "Veteran" |
| internationalization_level | CASE on foreigners_percentage | "Highly International", "International", "Mixed", "Mostly Domestic" |
| stadium_size_category | CASE on stadium_seats | "Large", "Medium", "Small", "Very Small" |
| transfer_strategy | CASE on net_transfer_balance | "Major Seller", "Net Seller", etc. |

---

### football_marts.clubs_analytics (TABLE)
**Purpose:** Materialized analytical dataset with rankings and percentiles

**Includes all stg_clubs columns PLUS:**

| Column | Type | Description | Calculation |
|--------|------|-------------|-------------|
| transfer_balance_per_player | FLOAT64 | Net transfer / squad size | net_transfer_balance / squad_size |
| national_team_percentage | FLOAT64 | % of squad in national teams | (national_team_players / squad_size) * 100 |
| squad_quality_score | FLOAT64 | Custom quality metric | (foreigners_pct * 0.3) + (national_players * 5) + age_bonus |
| stadium_rank | INT64 | Global rank by stadium size | ROW_NUMBER() OVER (ORDER BY stadium_seats DESC) |
| internationalization_rank | INT64 | Global rank by foreign % | ROW_NUMBER() OVER (ORDER BY foreigners_pct DESC) |
| net_seller_rank | INT64 | Rank by transfer balance | ROW_NUMBER() OVER (ORDER BY net_transfer_balance DESC) |
| quality_rank | INT64 | Rank by quality score | ROW_NUMBER() OVER (ORDER BY squad_quality_score DESC) |
| stadium_percentile | FLOAT64 | Percentile 0-1 | PERCENT_RANK() OVER (ORDER BY stadium_seats) |
| international_percentile | FLOAT64 | Percentile 0-1 | PERCENT_RANK() OVER (ORDER BY foreigners_pct) |
| is_large_stadium | BOOLEAN | Stadium >= 60k | stadium_seats >= 60000 |
| is_highly_international | BOOLEAN | Foreigners >= 75% | foreigners_percentage >= 75 |
| is_net_seller | BOOLEAN | Transfer balance > €10M | net_transfer_balance > 10000000 |
| is_net_buyer | BOOLEAN | Transfer balance < -€10M | net_transfer_balance < -10000000 |
| has_many_nationals | BOOLEAN | National team players >= 10 | national_team_players >= 10 |

---

### football_marts.vw_clubs_enriched (VIEW)
**Purpose:** Denormalized view joining clubs with leagues, includes league/tier averages

**All columns from clubs_analytics PLUS:**

| Column | Type | Description |
|--------|------|-------------|
| league_name | STRING | From leagues dimension |
| country | STRING | From leagues dimension |
| league_tier | STRING | From leagues dimension |
| league_avg_quality | FLOAT64 | AVG(quality) OVER (PARTITION BY league) |
| league_avg_foreign_pct | FLOAT64 | AVG(foreigners_pct) OVER (PARTITION BY league) |
| league_avg_transfer_balance | FLOAT64 | AVG(transfers) OVER (PARTITION BY league) |
| tier_avg_quality | FLOAT64 | AVG(quality) OVER (PARTITION BY tier) |
| tier_avg_foreign_pct | FLOAT64 | AVG(foreigners_pct) OVER (PARTITION BY tier) |

---

### football_marts.vw_league_summary (VIEW)
**Purpose:** Pre-aggregated league-level KPIs for dashboards

| Column | Aggregation | Description |
|--------|-------------|-------------|
| total_clubs | COUNT(*) | Clubs in league |
| min/max/avg_quality | MIN/MAX/AVG | Quality score range |
| quality_range | MAX - MIN | Spread of quality |
| stddev_quality | STDDEV() | Standard deviation |
| avg_stadium_capacity | AVG() | Average stadium size |
| total_stadium_capacity | SUM() | Combined capacity |
| total_transfer_balance | SUM() | League net transfers |
| net_sellers/buyers_count | SUM(CASE...) | Strategy counts |
| pct_sellers/buyers | COUNT/TOTAL | Percentage breakdown |
| coefficient_of_variation | (STDDEV/AVG)*100 | Normalized variability |
| balance_rating | CASE | "Very Unbalanced", "Unbalanced", etc. |

---

### football_marts.vw_top_performers (VIEW)
**Purpose:** Pre-ranked clubs for leaderboards and comparisons

**Includes:**
- All core metrics from vw_clubs_enriched
- global_rank, league_rank, tier_rank
- global_percentile, league_percentile (0-100 scale)
- quality_vs_league_avg, quality_vs_tier_avg
- global_tier_label ("Global Top 10", "Top Quartile", etc.)

---

### football_marts.summary_facts (TABLE)
**Purpose:** High-level summary statistics by scope (Global/Tier/League)

| Column | Description |
|--------|-------------|
| scope | "Global", "Tier", "League" |
| scope_name | "All Clubs", "Top 5", "Premier League", etc. |
| total_clubs | Count |
| avg/min/max_quality | Quality metrics |
| total_transfers | Sum of net transfers |
| avg_foreign_pct | Average internationalization |
| avg_stadium | Average capacity |

**Usage:** Powers dashboard KPI cards

---

## Metric Definitions

### squad_quality_score
**Formula:**
```
(foreigners_percentage * 0.3) + 
(national_team_players * 5) + 
(age_bonus)

where age_bonus = 20 if age BETWEEN 24 AND 28, else 0
```

**Range:** 0-160+
**Interpretation:** Higher = better squad quality
**Top score:** Manchester City (156.1)

### coefficient_of_variation (CV)
**Formula:**
```
(STDDEV(quality) / AVG(quality)) * 100
```

**Range:** 0-150%
**Interpretation:**
- <30%: Low variability (consistent)
- 30-50%: Moderate variability
- 50-100%: High variability (elite-dominated)
- >100%: Extreme inequality

### transfer_strategy
**Classification:**
```
IF balance > €50M      → "Major Seller"
IF balance €10M-€50M   → "Net Seller"
IF balance €0-€10M     → "Minor Seller"
IF balance = €0        → "Balanced"
IF balance €0 to -€10M → "Minor Buyer"
IF balance -€10M to -€50M → "Net Buyer"
IF balance < -€50M     → "Major Buyer"
```

---

## Data Quality Notes

### Known Limitations
1. **total_market_value:** Empty for all clubs in source data
2. **coach_name:** Not included in analytical layers (inconsistent data)
3. **last_season:** Varies by club, not standardized

### Data Completeness
- **451 total clubs** in raw data
- **362 clubs** with complete analytical data (squad_quality_score + net_transfer_balance)
- **11 leagues** identified and mapped
- **0 orphaned records** (100% JOIN success rate)

### Update Frequency
- **Current state:** Static snapshot (Kaggle dataset)
- **Future state (Week 4):** Could be automated with Cloud Scheduler

---

## Common Query Patterns

### Filter Top Performers
```sql
SELECT * FROM football_marts.vw_top_performers
WHERE global_rank <= 50
```

### Compare Club to League Average
```sql
SELECT 
  club_name,
  squad_quality_score,
  league_avg_quality,
  squad_quality_score - league_avg_quality as gap
FROM football_marts.vw_clubs_enriched
WHERE club_name = 'Real Madrid Club de Fútbol'
```

### Get League KPIs
```sql
SELECT * FROM football_marts.vw_league_summary
WHERE league_tier = 'Top 5'
ORDER BY avg_quality DESC
```

### Find All Net Sellers
```sql
SELECT club_name, league_name, net_transfer_balance
FROM football_marts.vw_clubs_enriched
WHERE is_net_seller = TRUE
ORDER BY net_transfer_balance DESC
```