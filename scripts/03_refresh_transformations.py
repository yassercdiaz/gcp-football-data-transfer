"""
Script to refresh all transformations (staging views and marts)
Run this after updating raw data or transformation logic
"""

from google.cloud import bigquery
from dotenv import load_dotenv
import os

load_dotenv()

PROJECT_ID = os.getenv("PROJECT_ID")

def run_query_from_file(client, sql_file_path, description):
    """Execute SQL from file"""
    
    print(f"🔄 {description}...")
    
    with open(sql_file_path, 'r', encoding='utf-8') as f:
        sql = f.read()
    
    query_job = client.query(sql)
    query_job.result()
    
    print(f"✅ {description} completed!")

def refresh_all_transformations():
    """Refresh all views and tables in order"""
    
    client = bigquery.Client(project=PROJECT_ID)
    
    print("🚀 Starting transformation refresh...\n")
    
    # Step 1: Refresh staging view
    run_query_from_file(
        client,
        "queries/transformations/stg_clubs.sql",
        "Refreshing staging view (stg_clubs)"
    )
    
    # Step 2: Refresh analytics mart
    run_query_from_file(
        client,
        "queries/transformations/clubs_analytics_mart.sql",
        "Refreshing analytics mart (clubs_analytics)"
    )
    
    # Step 3: Get row counts
    print("\n📊 Verifying data...")
    
    tables = [
        "football_transfer_raw.clubs",
        "football_staging.stg_clubs",
        "football_marts.clubs_analytics"
    ]
    
    for table in tables:
        query = f"SELECT COUNT(*) as count FROM `{PROJECT_ID}.{table}`"
        result = list(client.query(query).result())
        count = result[0]['count']
        print(f"  {table}: {count} rows")
    
    print("\n🎉 All transformations refreshed successfully!")
    print(f"🔗 View in BigQuery: https://console.cloud.google.com/bigquery?project={PROJECT_ID}")

if __name__ == "__main__":
    refresh_all_transformations()