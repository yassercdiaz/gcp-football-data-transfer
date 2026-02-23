# Insights - Data Transformations & Analytics

## 🎯 Overview
In this part, the project focused on creating clean, analytical datasets through staging views and materialized marts, then extracting business insights through advanced SQL analytics.

## 📊 Key Findings

### 1. Transfer Market Dynamics

#### The 3-5-20 Rule
- **3.5%** of clubs are Major Sellers (16 clubs generating €1.16B)
- **5%** are Major Buyers (20 clubs spending -€2.59B)
- **20%** are balanced or unknown strategy

#### Financial Concentration
- Top 16 sellers average **€72.6M profit each**
- Top 20 buyers average **-€129.8M spending each**
- **Buyers spend 79% more than sellers earn** (indicating market inefficiency or superstar premium)

#### Age-Strategy Correlation
| Strategy | Avg Age | Pattern |
|----------|---------|---------|
| Major Seller | 25.8 | Young talents with potential |
| Balanced | 25.6 | Development phase |
| Major Buyer | 26.7 | Prime-age established players |

**Insight:** Clubs buy peak-performance players (26-27) and sell promising youth (25-26).

---

### 2. Club Segmentation Analysis

#### Elite Tier: "Mature + Highly International"
- **14 clubs** (3% of dataset)
- **81.4% foreign players**
- **Quality score: 99.1** (highest)
- **Strategy:** Net buyers (-€12.4M avg)
- **Examples:** Real Madrid, Bayern Munich, Manchester City

**Profile:** Global brands with resources to attract international talent, buying established stars.

#### Growth Tier: "Young + International"  
- **70 clubs** (15% of dataset)
- **60.6% foreign players**
- **Quality score: 71.5**
- **Strategy:** Slight net sellers (+€3M avg)
- **Examples:** Brighton, Southampton, Lyon

**Profile:** Development clubs that buy young internationals, develop them, and sell for profit.

#### Niche Tier: "Very Young + Highly International"
- **3 clubs** (rare model)
- **80.1% foreign players**
- **Strategy:** Major net sellers (+€20.7M avg)

**Profile:** International academies - buy young foreign prospects, develop, and flip for significant profit.

#### Regional Tier: "Mostly Domestic"
- **Multiple segments** (40+ clubs)
- **11-18% foreign players**
- **Quality score: 5-31** (lowest)
- **Strategy:** Minor sellers or balanced

**Profile:** Local clubs with limited international appeal, smaller stadiums, lower budgets.

---

### 3. Internationalization Patterns

#### The 75% Threshold
Clubs with **≥75% foreign players**:
- Have **higher quality scores** (avg 82+)
- Are **net buyers** (-€6M to -€12M)
- Have **larger stadiums** (27k-31k seats)
- Concentrated in **elite European leagues**

#### The Domestic Penalty
Clubs with **<25% foreign players**:
- Have **lower quality scores** (avg 5-31)
- Are minor sellers or balanced
- Have **smaller stadiums** (9k-20k seats)
- Limited international competitiveness

**Key Insight:** Internationalization correlates strongly with club quality and financial strategy.

---

### 4. Stadium Size as Quality Indicator

| Stadium Category | Avg Foreign % | Avg Transfer Balance | Quality Score |
|------------------|---------------|----------------------|---------------|
| Large (60k+) | 69% | -€35M (buyer) | 85+ |
| Medium (30-60k) | 58% | -€5M | 65-75 |
| Small (15-30k) | 42% | +€2M (seller) | 45-55 |
| Very Small (<15k) | 28% | +€1M | 20-35 |

**Insight:** Stadium size predicts transfer strategy and internationalization level.

---

## 🔬 Statistical Correlations

### Results from 399 clubs with complete data:

| Metric Pair | Correlation | Interpretation |
|-------------|-------------|----------------|
| **Stadium Size ↔ Internationalization** | +0.216 | Weak positive - Large stadiums slightly more international |
| **Age ↔ Transfer Balance** | -0.127 | Very weak negative - Older squads slightly more likely to buy |
| **Internationalization ↔ Transfer Balance** | -0.085 | Almost zero - No relationship |
| **Squad Size ↔ Stadium Size** | +0.073 | Almost zero - No relationship |

### Key Findings:

#### 1. Weak Correlations Indicate Multiple Strategies
The low correlation values (all < 0.25) reveal that **there is no single "winning formula"** in football club management. Successful clubs follow diverse strategies:

- **Strategy A:** Buy international stars (Real Madrid: 68% foreign, -€165M)
- **Strategy B:** Develop foreign youth (AS Monaco: 100% foreign, +€132M)
- **Strategy C:** Mix domestic/international (varies widely)

#### 2. Stadium Size ≠ Squad Size
Despite intuition, stadium capacity doesn't correlate with squad size (0.073). This is because:
- UEFA and league regulations limit squad sizes (typically 23-30 players)
- Small clubs can't afford 30+ players even with small stadiums
- Large clubs don't need 50+ players despite 80k stadiums

#### 3. Internationalization Has Two Paths
The near-zero correlation between internationalization and transfer balance (-0.085) reveals two distinct models:

**Path 1: Elite Buyer Model**
- Buy established international stars
- Example: Real Madrid (68% foreign, -€165M buyer)

**Path 2: Development Model**  
- Buy/recruit young foreign prospects
- Develop and sell for profit
- Example: AS Monaco (100% foreign, +€132M seller)

Both are highly international but opposite financial strategies.

#### 4. Age is Not Destiny
The weak age-transfer correlation (-0.127) shows that squad age doesn't strongly predict buying/selling behavior. Young squads can be either:
- Development projects (selling)
- Investment in future (buying young talent)

### Statistical Summary:
```
Total clubs analyzed: 399
Average stadium: 24,831 seats
Average age: 25.7 years
Average foreign %: 47.7%
Average transfer balance: -€346,206 (slight net buyers overall)
```

**Conclusion:** The low correlations prove that football club success requires **strategic fit**, not following universal formulas. Different market positions (elite, growth, regional) demand different approaches to internationalization, transfers, and squad building.
---

## 🏗️ Technical Implementation

### Data Architecture
```
RAW Layer (football_transfer_raw.clubs)
  ↓ [Type conversion, NULL handling, text parsing]
STAGING Layer (football_staging.stg_clubs)
  ↓ [Business logic, calculated fields, rankings]
MARTS Layer (football_marts.clubs_analytics)
  ↓ [Analytical queries]
INSIGHTS
```

### Key Transformations

#### 1. Transfer Balance Cleaning
**Challenge:** Text values like "+€132.57m", "€-101k", "+-0"

**Solution:**
```sql
CASE
  WHEN REGEXP_CONTAINS(net_transfer_record, r'm$') THEN
    SAFE_CAST(REGEXP_REPLACE(...) AS FLOAT64) * 1000000
  WHEN REGEXP_CONTAINS(net_transfer_record, r'k$') THEN
    SAFE_CAST(REGEXP_REPLACE(...) AS FLOAT64) * 1000
  ELSE NULL
END
```

**Result:** 355 clubs with clean numeric transfer balances.

#### 2. Squad Quality Score (Custom Metric)
```sql
ROUND(
  (foreigners_percentage * 0.3) +
  (national_team_players * 5) +
  (CASE WHEN age BETWEEN 24-28 THEN 20 ELSE 0 END)
, 1)
```

**Components:**
- 30% weight on internationalization
- 5 points per national team player
- 20 bonus points for optimal age range

#### 3. Strategic Categorization
Created 7-tier transfer strategy classification:
- Major Seller (>€50M)
- Net Seller (€10M-€50M)
- Minor Seller (€0-€10M)
- Balanced
- Minor Buyer (€0 to -€10M)
- Net Buyer (-€10M to -€50M)
- Major Buyer (<-€50M)

---

## 💡 Business Implications

### For Scouts
- Focus on "Young + International" clubs for undervalued talent
- "Very Young + Highly International" clubs are hidden gem suppliers
- Avoid "Mostly Domestic" clubs for international competitions

### For Club Management
- Internationalization is essential for competitiveness
- Optimal squad age is 24-28 for balance of value and performance
- Small clubs should adopt development-and-sell model

### For Investors
- Major Buyers are high-risk, high-reward (expensive but competitive)
- Net Sellers offer sustainable business model
- Stadium capacity is a strong quality predictor

---

## 📚 Key Takeaway

**The data reveals that modern football is increasingly internationalized, with clear tiers of clubs distinguished by their foreign player percentage, transfer strategy, and stadium size. The most successful clubs (by quality score) are those that either buy established international talent or develop young international prospects for profit.**