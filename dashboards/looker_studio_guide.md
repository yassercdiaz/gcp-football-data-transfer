# Looker Studio Dashboard Guide

## 🎯 Dashboard Overview
Create an interactive dashboard to visualize the European football club analytics.

## 📊 Recommended Dashboard Structure

### Page 1: Global Overview
**KPI Cards (use `summary_facts` table):**
- Total Clubs Analyzed
- Average Squad Quality
- Total Transfer Balance (Global)
- Average Foreign Player %

**Charts:**
1. **Bar Chart:** Top 10 Clubs by Quality Score
   - Data source: `vw_top_performers`
   - Dimension: club_name
   - Metric: quality_score
   - Filter: global_rank <= 10

2. **Geo Map:** Clubs by Country
   - Data source: `vw_clubs_enriched`
   - Dimension: country
   - Metric: COUNT(club_name)

3. **Scatter Plot:** Quality vs Transfer Balance
   - Data source: `vw_top_performers`
   - X-axis: transfer_balance
   - Y-axis: quality_score
   - Color: league_tier

---

### Page 2: League Comparison
**Table:** League Summary
- Data source: `vw_league_summary`
- Columns: league_name, total_clubs, avg_quality, total_transfer_balance, balance_rating

**Charts:**
1. **Column Chart:** Average Quality by League
   - Dimension: league_name
   - Metric: avg_quality
   - Sort: Descending

2. **Stacked Bar:** Transfer Strategy Distribution
   - Dimension: league_name
   - Metrics: net_sellers_count, net_buyers_count
   - Type: 100% stacked

3. **Line Chart:** Competitive Balance
   - Dimension: league_name (sorted by quality_range)
   - Metrics: min_quality, avg_quality, max_quality

---

### Page 3: Club Deep Dive
**Filters:**
- League dropdown (from `vw_clubs_enriched.league_name`)
- Quality tier dropdown (global_tier_label)
- Transfer strategy dropdown

**Scorecard:** Selected Club Details
- Data source: `vw_top_performers`
- Metrics: quality_score, global_rank, league_rank, transfer_balance

**Charts:**
1. **Table:** All Clubs (filtered)
   - Data source: `vw_top_performers`
   - Columns: club_name, quality_score, global_rank, league_rank, transfer_balance, transfer_strategy

2. **Gauge:** Club vs League Average
   - Metric: quality_vs_league_avg
   - Max: 50, Min: -50

---

## 🔗 Data Source Connection

### Step 1: Connect to BigQuery
1. Go to Looker Studio: https://lookerstudio.google.com
2. Create → Data Source
3. Select "BigQuery"
4. Choose project: `gcp-football-data-transfer`

### Step 2: Add Tables/Views
Add these as separate data sources:
- `football_marts.vw_clubs_enriched` (main data source)
- `football_marts.vw_league_summary` (league KPIs)
- `football_marts.vw_top_performers` (rankings)
- `football_marts.summary_facts` (global KPIs)

### Step 3: Create Calculated Fields (if needed)
**Example: Quality Rank Label**
```
CASE
  WHEN global_rank <= 10 THEN "Top 10"
  WHEN global_rank <= 50 THEN "Top 50"
  ELSE "Other"
END
```

---

## 🎨 Design Recommendations

### Color Palette
- **Top 5 Leagues:** Blue (#1E88E5)
- **Secondary Leagues:** Green (#43A047)
- **Other Leagues:** Gray (#757575)

### Transfer Strategy Colors
- **Major Seller:** Dark Green (#2E7D32)
- **Net Seller:** Light Green (#66BB6A)
- **Balanced:** Gray (#9E9E9E)
- **Net Buyer:** Light Red (#EF5350)
- **Major Buyer:** Dark Red (#C62828)

---

## 📈 Sample Insights to Highlight

1. **Premier League spends €1.33B more than all other leagues combined**
2. **Ligue 1 is the only Top 5 league that is a net seller (+€551M)**
3. **All Top 5 leagues are "Very Unbalanced" (quality range >89)**
4. **Man City has 17.5 point gap to #2 club (largest in top 10)**
5. **Belgian clubs have 0% net buyers (pure development model)**

---

## 🚀 Next Steps (Week 4)

In Week 4, we'll:
- Build the actual Looker Studio dashboard
- Add filters and interactivity
- Create drill-through reports
- Schedule automatic data refreshes with Cloud Scheduler