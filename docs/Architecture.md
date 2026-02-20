# Architecture Documentation

## 📐 System Architecture

### Current Implementation 
```
┌─────────────────────────────────────────────────────────────────┐
│                         LOCAL ENVIRONMENT                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐           ┌─────────────────────────────┐     │
│  │  clubs.csv   │ ────────> │  Python Scripts             │     │
│  │  (451 clubs) │           │  - 01_upload_to_gcs.py      │     │
│  └──────────────┘           │  - 02_load_to_bigquery.py   │     │
│                             └─────────────────────────────┘     │
│                                          │                      │
└──────────────────────────────────────────┼──────────────────────┘
                                           │
                                           │ Upload via 
                                           │ google-cloud-storage
                                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GOOGLE CLOUD PLATFORM                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐     │
│  │              CLOUD STORAGE (GCS)                       │     │
│  │  Bucket: gcp-football-clubs-data-2025                  │     │
│  │                                                        │     │
│  │  └── raw/                                              │     │
│  │       └── clubs.csv (Source of Truth)                  │     │
│  └────────────────────────────────────────────────────────┘     │
│                           │                                     │
│                           │ Load via                            │
│                           │ google-cloud-bigquery               │
│                           ▼                                     │
│  ┌────────────────────────────────────────────────────────┐     │
│  │                   BIGQUERY                             │     │
│  │  Dataset: football_transfer_raw                        │     │
│  │                                                        │     │
│  │  Tables:                                               │     │
│  │  └── clubs (451 rows, 17 columns)                      │     │
│  │                                                        │     │
│  │  Schema:                                               │     │
│  │  - club_id (STRING)                                    │     │
│  │  - name (STRING)                                       │     │
│  │  - stadium_seats (INT64)                               │     │
│  │  - squad_size (INT64)                                  │     │
│  │  - average_age (FLOAT64)                               │     │
│  │  - foreigners_percentage (FLOAT64)                     │     │
│  │  - net_transfer_record (STRING) ← needs cleaning       │     │
│  │  - ... (10 more columns)                               │     │
│  └────────────────────────────────────────────────────────┘     │
│                           │                                     │
│                           │ Query via                           │
│                           │ BigQuery Console / SQL              │
│                           ▼                                     │
│  ┌────────────────────────────────────────────────────────┐     │
│  │              SQL ANALYTICS (Queries)                   │     │
│  │                                                        │     │
│  │  - Exploratory queries                                 │     │
│  │  - Aggregations and rankings                           │     │
│  │  - Data quality checks                                 │     │
│  │  - Transformation logic                                │     │
│  └────────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

1. **Extract:** Local CSV file containing football club data
2. **Load:** Upload to Cloud Storage (data lake / staging)
3. **Load:** Import from GCS to BigQuery (data warehouse)
4. **Transform:** SQL queries clean and analyze data
5. **Analyze:** Business insights via exploratory queries

## 🛠️ Components

### Cloud Storage
- **Purpose:** Raw data storage and staging area
- **Benefits:** 
  - Cheap storage ($0.020/GB)
  - Decouples source from warehouse
  - Version history possible
- **Location:** us-central1
- **Storage Class:** STANDARD

### BigQuery
- **Purpose:** Data warehouse for analytics
- **Benefits:**
  - Serverless (no infrastructure management)
  - SQL interface
  - Scales automatically
  - Columnar storage for fast queries
- **Location:** us-central1
- **Pricing Model:** Pay-per-query (1 TB free/month)

### Python Automation
- **Scripts:** Automate upload and loading processes
- **Libraries:** 
  - `google-cloud-storage`: GCS interactions
  - `google-cloud-bigquery`: BigQuery operations
  - `python-dotenv`: Environment configuration

## 🔐 Security

- **Authentication:** Application Default Credentials (ADC)
- **Configuration:** Environment variables via `.env`
- **Git Security:** `.gitignore` prevents credential leaks
- **IAM:** User-level permissions via GCP console

## 🎯 Design Decisions

### Why Cloud Storage before BigQuery?
- **Decoupling:** Source data separate from warehouse
- **Flexibility:** Easy to reload or reprocess data
- **Cost:** Cheaper storage for raw files
- **Best Practice:** Industry standard ELT pattern

### Why BigQuery?
- **Learning Value:** Industry-standard data warehouse
- **Cost:** Free tier perfect for education
- **Performance:** Fast analytics on large datasets
- **SQL:** Familiar query language

### Why Python scripts vs manual commands?
- **Automation:** Repeatable processes
- **Version Control:** Track changes in Git
- **Collaboration:** Others can run same pipeline
- **Portfolio:** Demonstrates coding skills

## 💰 Cost Analysis (Week 1)

| Service | Usage | Cost |
|---------|-------|------|
| Cloud Storage | 5 MB | $0.00 (within free tier) |
| BigQuery Storage | 5 MB | $0.00 (within free tier) |
| BigQuery Queries | ~100 MB processed | $0.00 (within 1 TB free) |
| **Total** | | **$0.00** |

All operations stayed well within GCP's generous free tier.