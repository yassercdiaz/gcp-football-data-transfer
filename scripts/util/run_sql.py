"""
Helper script to run SQL files from command line
"""
from google.cloud import bigquery
from dotenv import load_dotenv
import sys
import os

load_dotenv()

PROJECT_ID = os.getenv("PROJECT_ID")

def run_sql_file(sql_file_path):
    """Execute SQL from file"""
    
    if not os.path.exists(sql_file_path):
        print(f"❌ Error: File not found {sql_file_path}")
        return
    
    with open(sql_file_path, 'r', encoding='utf-8') as f:
        sql = f.read()
    
    client = bigquery.Client(project=PROJECT_ID)
    
    print(f"🔄 Executing SQL from {sql_file_path}...")
    query_job = client.query(sql)
    query_job.result()  # Wait for completion
    
    print(f"✅ SQL executed successfully!")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python run_sql.py <path_to_sql_file>")
        sys.exit(1)
    
    sql_file = sys.argv[1]
    run_sql_file(sql_file)