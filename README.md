# ⚽ Football Tansfer Data Pipeline on GCP

A hands-on learning project implementing a complete ELT data pipeline on Google Cloud Platform.

## 🎯 Objective
Learn GCP by building a real-world data pipeline featuring:
- Cloud Storage
- BigQuery
- Python automation
- dbt Core

## 📊 Dataset
- **Source:** Kaggle - Player Scores Dataset
- **File:** clubs.csv
- **Records:** 451 football clubs
- **Columns:** 17 (name, stadium, squad, internationalization, etc.)

## 🏗️ Architecture
```
Local CSV → Cloud Storage → BigQuery → dbt → Looker Studio
```

## 📁 Project Structure
```
├── data/raw/          # Original data files
├── scripts/           # Python automation scripts
├── queries/           # Organized SQL queries
└── docs/              # Documentation
```

## 🛠️ Technologies
- Google Cloud Platform
- Python 3.11
- BigQuery
- Cloud Storage

## 📚 Key Learnings
[Will be updated with insights from each week]

## 🔧 Setup

1. **Clone the repository**
```bash
git clone https://github.com/your-username/gcp-football-data-transfer.git
cd gcp-football-data-transfer
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure environment variables**
```bash
# Copy the example file
cp .env.example .env

# Edit .env with your GCP project details
# PROJECT_ID=your-project-id
# BUCKET_NAME=your-bucket-name
# etc.
```

4. **Authenticate with GCP**
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

5. **Run the pipeline**
```bash
# Upload to Cloud Storage
python scripts/01_upload_to_gcs.py

# Load to BigQuery
python scripts/02_load_to_bigquery.py
```

## 📈 Sample Insights
- Real Madrid has the largest stadium (83,186 seats)
- AS Monaco has 100% foreign players
- AS Monaco is the biggest net seller (+€132M transfer balance)