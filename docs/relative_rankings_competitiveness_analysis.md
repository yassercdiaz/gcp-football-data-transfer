# Relative Rankings and Competitive Analysis of Leages Balance

## 🎯 Overview
This analysis is focused on mastering advanced window functions for relative rankings, competitive analysis, and statistical measures of league balance.

## 🛠️ Window Functions Implemented

### 1. LAG/LEAD - Neighbor Comparisons
**Purpose:** Compare each club with the club ranked immediately above/below.

**Key findings:**
- Manchester City: 17.5 point gap to #2 (Tottenham) - largest gap in top 10
- Positions 3-10: Gaps of only 0.3-2.9 points (highly competitive)
- Celtic (#5 global) has only 0.4 point gap to #4 (Liverpool)

### 2. NTILE - Quartile/Decile Classification
**Purpose:** Divide clubs into equal-sized groups for tier analysis.

**Global Quartiles:**
- Q1 (Elite - Top 25%): Man City (156.1) to ~90 quality
- Q2 (Strong): ~90 to ~60 quality
- Q3 (Average): ~60 to ~35 quality
- Q4 (Developing): <35 quality

**League-specific Quartiles:**
- Same club can be Q1 globally but Q2-Q3 in Premier League
- Bayern Munich: Q1 globally, Q1 in Bundesliga (undisputed leader)
- Dortmund: Q1 globally, Q2 in Bundesliga (73.3 percentile)

### 3. FIRST_VALUE/LAST_VALUE - League Extremes
**Purpose:** Identify best and worst clubs in each league.

**Bundesliga Example:**
- Best: Bayern Munich (120.0)
- Worst: SC Paderborn (30.8)
- Range: 89.2 points
- Dortmund gap from best: -25.0 points (despite being #2)

### 4. Running Totals - Cumulative Analysis
**Purpose:** Track cumulative transfer spending as clubs are added by quality rank.

**Bundesliga Pattern:**
- Top 3 clubs: €22.7M average (mix of buyers/sellers)
- Full league cumulative: +€117.7M (net sellers)
- Stuttgart cumulative pushes total from €15M to €135M (major seller)

### 5. PERCENT_RANK - Percentile Positioning
**Purpose:** Show where each club stands relative to league peers (0-100 scale).

**Key Patterns:**
- Dortmund: 73.3 percentile in Bundesliga (not Top 25%!)
- Real Madrid: 100 percentile in La Liga (obvious #1)
- Spending vs Quality mismatch: Some high-quality clubs are low spenders (Bayern), some low-quality are high spenders (Wolfsburg)

---

## 📊 Competitive Balance Analysis

### Global League Inequality Rankings

| Rank | League | Quality Range | CV (%) | Balance Rating |
|------|--------|---------------|--------|----------------|
| 1 | 🇪🇸 La Liga | 129.6 | 55.5% | 🔴 Very Unbalanced |
| 2 | 🇮🇹 Serie A | 128.5 | 53.7% | 🔴 Very Unbalanced |
| 3 | 🇹🇷 Süper Lig | 126.6 | 91.2% | 🔴 Very Unbalanced |
| 4 | 🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scotland | 122.5 | 56.7% | 🔴 Very Unbalanced |
| 5 | 🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League | 117.1 | 31.9% | 🔴 Very Unbalanced |
| 11 | 🇩🇪 Bundesliga | 89.2 | 40.5% | 🟡 Unbalanced |

### Key Insights

#### **1. All Top 5 Leagues Are "Very Unbalanced"**
- Quality ranges exceed 89 points in every Top 5 league
- Even "best" case (Bundesliga 89.2) shows massive gap between elite and bottom
- NO Top 5 league achieves "Moderately Balanced" or better

#### **2. Coefficient of Variation Reveals True Story**
**CV Formula:** (Standard Deviation / Mean) × 100

**Interpretation:**
- **<30%:** Low variability (consistent quality)
- **30-50%:** Moderate variability
- **50-100%:** High variability (dominant elites)
- **>100%:** Extreme chaos (Ukraine 116.7%)

**Findings:**
- **Premier League: 31.9%** - Most consistent despite high range
  - Explanation: Deep bench of 10-15 high-quality clubs
  - Man City is outlier, but top 15 are tightly packed
  
- **Bundesliga: 40.5%** - Moderate variability
  - Explanation: Bayern dominates, but mid-table is dense
  
- **Süper Lig: 91.2%** - Extreme inequality
  - Explanation: Galatasaray + few elites, then massive drop-off

#### **3. Inter-Quartile Range (IQR) Analysis**
**IQR = P75 - P25** (middle 50% of clubs)

| League | IQR | Interpretation |
|--------|-----|----------------|
| Serie A | 61.2 | Huge mid-table spread |
| Russia | 62.3 | Massive inequality |
| Bundesliga | 55.2 | Wide mid-table |
| Premier League | 38.7 | Tighter mid-table clustering |

**Insight:** Premier League's lower IQR (38.7) despite high range shows:
- Elite tier is far ahead (Man City 156.1)
- But mid-table (25th-75th percentile) is competitive
- Bundesliga's higher IQR (55.2) shows mid-table is more spread out

---

## 💡 Strategic Patterns Discovered

### **Pattern 1: Spending ≠ Quality (in Bundesliga)**

**High Quality, Low Spending:**
- Bayern Munich: Quality 120.0, Transfer +€12.9M (selling!)
- Spending percentile: 86.7% (high seller)

**High Spending, Lower Quality:**
- Wolfsburg: Quality 106.8 (93.3%), Transfer -€30.4M (0% - biggest buyer)
- Despite spending, only 4th in league

**Conclusion:** Bundesliga shows that smart management (Bayern) can beat checkbook (Wolfsburg).

---

### **Pattern 2: La Liga's Binary Structure**

**Elite Tier (Top 3):**
- Real Madrid: 135.4 (100%)
- Atlético: 130.9 (96.9%)
- Barcelona: 113.7 (93.8%)

**Median:** 45.6
**P25:** 39.1

**Gap:** Elite tier is 90+ points above median.

**Conclusion:** La Liga is effectively two leagues:
1. Real/Barça/Atlético (Champions League contenders)
2. Everyone else (fighting for Europa League)

---

### **Pattern 3: Scottish Paradox**

**Celtic:**
- Quality: 132.1 (#5 global)
- League percentile: 100% (obvious)
- Transfer: +€14.5M (net seller)

**Context:**
- Dominates weak league (range 122.5)
- Quality score inflated by no competition
- Yet sells players profitably to stronger leagues

**Model:** Dominate weak league → develop talent → sell to Top 5.

---

## 🔍 Technical Deep Dive

### Window Function Syntax Patterns

#### **1. Simple Window (All Rows)**
```sql
AVG(quality) OVER () as overall_avg
```

#### **2. Partitioned Window (By Group)**
```sql
AVG(quality) OVER (PARTITION BY league) as league_avg
```

#### **3. Ordered Window (Cumulative)**
```sql
SUM(transfers) OVER (
  PARTITION BY league 
  ORDER BY quality DESC
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) as cumulative_transfers
```

#### **4. Frame-Limited Window (Moving Average)**
```sql
AVG(transfers) OVER (
  PARTITION BY league
  ORDER BY quality DESC
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) as moving_avg_3
```

### Statistical Measures

| Measure | SQL Function | Purpose |
|---------|--------------|---------|
| **Standard Deviation** | `STDDEV(col)` | Measure spread around mean |
| **Percentiles** | `PERCENTILE_CONT(col, 0.75)` | Find specific cutoff values |
| **Coefficient of Variation** | `STDDEV/AVG * 100` | Normalized variability measure |
| **Inter-Quartile Range** | `P75 - P25` | Middle 50% spread |

---

## 📈 Business Implications

### For Fans
- **Premier League:** Most competitive at top (Big 6) but Man City dominates
- **Bundesliga:** Bayern dynasty unlikely to end, 89-point gap to bottom
- **La Liga:** Two-horse race (Real/Barça) with Atlético occasionally
- **Scottish Premiership:** Celtic's dominance makes league uncompetitive

### For Investors
- **High CV leagues (Turkey 91%, Russia 83%):** Risky investments, top-heavy
- **Low CV leagues (Premier 32%):** More stable mid-table valuations
- **IQR matters:** Leagues with low IQR (Premier 38.7) have more "safe" mid-table clubs

### For Players
- **Development path:** Start in secondary league (Portugal/Belgium) → move to mid-table Top 5 → elite club
- **Percentile positioning:** Being top 25% of Bundesliga (75+ percentile) qualifies you for Top 5 moves

---

## 📚 Key Takeaway

**Window functions reveal that European football operates as a pyramid with multiple layers of inequality:**
- Global: Man City (156.1) vs median club (40-50)
- League: Best vs worst ranges from 89 (Bundesliga) to 130 (La Liga)
- Tier: Top 5 (avg 69.3) vs Secondary (avg 43.5)

**No league has achieved true competitive balance. Even the "best" case (Bundesliga) has an 89-point range and 40.5% coefficient of variation.**