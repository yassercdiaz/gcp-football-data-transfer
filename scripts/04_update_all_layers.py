"""
Complete data pipeline refresh script
Runs all transformations in correct order
"""

from google.cloud import bigquery
from dotenv import load_dotenv
import os
from datetime import datetime

load_dotenv()

PROJECT_ID = os.getenv("PROJECT_ID")

def run_sql_file(client, file_path, description):
    """Execute SQL from file with error handling"""
    print(f"🔄 {description}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            sql = f.read()
        
        query_job = client.query(sql)
        query_job.result()
        print(f"✅ {description} completed!")
        return True
        
    except Exception as e:
        print(f"❌ Error in {description}: {str(e)}")
        return False

def get_row_count(client, table_ref):
    """Get row count for a table"""
    query = f"SELECT COUNT(*) as count FROM `{PROJECT_ID}.{table_ref}`"
    result = list(client.query(query).result())
    return result[0]['count']

def update_all_layers():
    """Run complete pipeline update"""
    
    client = bigquery.Client(project=PROJECT_ID)
    
    start_time = datetime.now()
    print("=" * 60)
    print("🚀 STARTING COMPLETE DATA PIPELINE REFRESH")
    print(f"📅 Started at: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # Track success/failure
    results = {}
    
    # Step 1: Staging layer
    print("\n📊 STEP 1: STAGING LAYER")
    print("-" * 60)
    results['stg_clubs'] = run_sql_file(
        client,
        "queries/transformations/stg_clubs.sql",
        "Refresh staging view (stg_clubs)"
    )
    
    # Step 2: Marts layer
    print("\n🏗️ STEP 2: MARTS LAYER")
    print("-" * 60)
    results['clubs_analytics'] = run_sql_file(
        client,
        "queries/transformations/clubs_analytics_mart.sql",
        "Refresh analytics mart (clubs_analytics)"
    )
    
    results['vw_clubs_enriched'] = run_sql_file(
        client,
        "queries/transformations/vw_clubs_enriched.sql",
        "Refresh enriched clubs view"
    )
    
    results['vw_league_summary'] = run_sql_file(
        client,
        "queries/transformations/vw_league_summary.sql",
        "Refresh league summary view"
    )
    
    results['vw_top_performers'] = run_sql_file(
        client,
        "queries/transformations/vw_top_performers.sql",
        "Refresh top performers view"
    )
    
    results['summary_facts'] = run_sql_file(
        client,
        "queries/transformations/summary_facts.sql",
        "Refresh summary facts table"
    )
    
    # Step 3: Verification
    print("\n🔍 STEP 3: DATA VERIFICATION")
    print("-" * 60)
    
    tables_to_check = [
        "football_transfer_raw.clubs",
        "football_staging.stg_clubs",
        "football_marts.clubs_analytics",
        "football_marts.summary_facts"
    ]
    
    print(f"{'Table':<50} {'Row Count':>10}")
    print("-" * 60)
    
    for table in tables_to_check:
        try:
            count = get_row_count(client, table)
            print(f"{table:<50} {count:>10,}")
        except Exception as e:
            print(f"{table:<50} {'ERROR':>10}")
    
    # Step 4: Summary
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    
    print("\n" + "=" * 60)
    print("📈 PIPELINE REFRESH SUMMARY")
    print("=" * 60)
    
    successful = sum(1 for v in results.values() if v)
    total = len(results)
    
    print(f"✅ Successful: {successful}/{total}")
    print(f"⏱️  Duration: {duration:.1f} seconds")
    print(f"🕐 Completed at: {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    
    if successful == total:
        print("\n🎉 All transformations completed successfully!")
        print(f"🔗 View in BigQuery: https://console.cloud.google.com/bigquery?project={PROJECT_ID}")
    else:
        print(f"\n⚠️  {total - successful} transformation(s) failed. Check logs above.")
    
    print("=" * 60)

if __name__ == "__main__":
    update_all_layers()