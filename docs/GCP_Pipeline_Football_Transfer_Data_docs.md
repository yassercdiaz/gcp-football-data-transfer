# GCP Fundamentals Implement on The Project

## 🎯 Overview
This project is focused on setting up the foundational infrastructure for a data pipeline on Google Cloud Platform, from local files to a fully queryable data warehouse.

## 🏗️ Architecture Implemented
```
Local CSV File (clubs.csv)
        ↓
   Cloud Storage (GCS Bucket)
        ↓
    BigQuery (Data Warehouse)
        ↓
  SQL Analytics (Queries)
```
For detailed architecture documentation, see [docs/Architecture.md](docs/Architecture.md)

## 📚 Key Concepts Learned

### 1. Google Cloud Storage (GCS)
- **What it is:** Object storage service, similar to Amazon S3
- **Use case:** Store raw data files before processing
- **Key operations:**
  - Creating buckets with `gsutil mb`
  - Uploading files with `gsutil cp`
  - Organizing data with folder-like prefixes

**Practical example:**
```bash
gsutil mb -p PROJECT_ID -l REGION gs://bucket-name
gsutil cp local-file.csv gs://bucket-name/path/
```

### 2. BigQuery
- **What it is:** Serverless data warehouse for analytics
- **Key features:**
  - SQL-based querying
  - Automatic schema detection
  - Petabyte-scale processing
  - Pay-per-query pricing model

**Free tier:**
- 10 GB storage/month
- 1 TB queries/month
- Perfect for learning projects

### 3. Data Pipeline Automation
- **Before:** Manual commands for each step
- **After:** Python scripts with environment variables
- **Benefits:**
  - Reproducibility
  - Version control
  - Easy collaboration

### 4. Data Quality Issues Encountered

#### Issue 1: Empty Columns
- **Problem:** `total_market_value` column was completely empty
- **Solution:** Pivoted analysis to other metrics (stadiums, age, internationalization)
- **Lesson:** Real-world data is messy; adaptability is key

#### Issue 2: Incorrect Data Types
- **Problem:** Numeric fields detected as STRING
- **Solution:** Used `SAFE_CAST()` and `REGEXP_REPLACE()` for cleaning
- **Lesson:** Always validate schema after auto-detection

#### Issue 3: Text Formatting in Numbers
- **Problem:** Transfer values like "+€3.06m", "€-101k"
- **Solution:** Created regex-based cleaning logic
- **Lesson:** Data cleaning is 80% of the work in data engineering

## 🛠️ Technical Skills Developed

### Python
- Google Cloud client libraries (`google-cloud-storage`, `google-cloud-bigquery`)
- Environment variables with `python-dotenv`
- Error handling and validation

### SQL
- Window functions (`ROW_NUMBER()`, `PERCENT_RANK()`)
- CTEs (Common Table Expressions)
- Complex CASE statements
- Regular expressions with `REGEXP_CONTAINS()` and `REGEXP_REPLACE()`
- Aggregations with `GROUP BY` and `HAVING`

### GCP CLI
- Project configuration with `gcloud config`
- Service enablement
- Authentication with ADC (Application Default Credentials)

### Git/GitHub
- `.gitignore` for security
- Professional project structure
- Meaningful commit messages

## 📊 Interesting Insights Found

### Stadium Analysis
- **Largest stadium:** Real Madrid's Santiago Bernabéu (83,186 seats)
- **Highest capacity per player:** Borussia Dortmund (3,390 seats/player)

### Internationalization
- **Most international club:** AS Monaco (100% foreign players)
- **Trend:** French and Italian clubs tend to be more international

### Transfer Balance
- **Biggest net seller:** AS Monaco (+€132.57M)
- **Strategy pattern:** Smaller clubs tend to be net sellers; large clubs are net buyers

### Age Distribution
- **Average age:** 25.46 years across all clubs
- **Youngest squads:** Turkish and Portuguese clubs
- **Veteran squads:** Rare (<5% of dataset)

## 🚧 Challenges Overcome

1. **Authentication:** Configured ADC for Python scripts
2. **Path issues:** Learned difference between relative paths when running from different directories
3. **Data types:** Mastered type conversion with SAFE_CAST
4. **Text parsing:** Used regex to extract numbers from formatted strings

## 🎓 Best Practices

### Security
- Never commit credentials to Git
- Use `.env` for configuration
- Always include `.env.example` for documentation

### Code Organization
- Separate scripts by function (upload, load, transform)
- Keep queries in organized folders
- Document code with clear comments

### Data Engineering
- Validate data after each step
- Handle edge cases (NULL values, empty strings)
- Use CTEs for readable complex queries
