"""
Script to load data from Cloud Storage to BigQuery
Author: [Your name]
Date: 2025-02-18
"""

from google.cloud import bigquery
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Configuration from .env
PROJECT_ID = os.getenv("PROJECT_ID")
DATASET_ID = os.getenv("DATASET_ID")
TABLE_ID = os.getenv("TABLE_ID")
GCS_URI = os.getenv("GCS_URI")
LOCATION = os.getenv("LOCATION")

def create_dataset(client, dataset_id):
    """Create BigQuery dataset if it doesn't exist"""
    dataset_ref = f"{PROJECT_ID}.{dataset_id}"
    
    try:
        client.get_dataset(dataset_ref)
        print(f"📊 Dataset {dataset_id} already exists")
    except:
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = LOCATION
        client.create_dataset(dataset)
        print(f"✅ Dataset {dataset_id} created")

def load_csv_to_bigquery(client, dataset_id, table_id, gcs_uri):
    """
    Load CSV from Cloud Storage to BigQuery
    
    Args:
        client: BigQuery client
        dataset_id: BigQuery dataset name
        table_id: BigQuery table name
        gcs_uri: GCS URI of the CSV file
    """
    
    table_ref = f"{PROJECT_ID}.{dataset_id}.{table_id}"
    
    # Configure load job
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=True,
        write_disposition="WRITE_TRUNCATE"  # Replace table if exists
    )
    
    # Load data
    print(f"📤 Loading {gcs_uri} to {table_ref}...")
    load_job = client.load_table_from_uri(
        gcs_uri,
        table_ref,
        job_config=job_config
    )
    
    # Wait for job to complete
    load_job.result()
    
    # Get table info
    table = client.get_table(table_ref)
    print(f"✅ Loaded {table.num_rows} rows to {table_ref}")

if __name__ == "__main__":
    # Validate environment variables
    if not all([PROJECT_ID, DATASET_ID, TABLE_ID, GCS_URI, LOCATION]):
        print("❌ Error: Missing environment variables. Check your .env file")
        exit(1)
    
    # Initialize BigQuery client
    client = bigquery.Client(project=PROJECT_ID)
    
    # Create dataset
    create_dataset(client, DATASET_ID)
    
    # Load data
    load_csv_to_bigquery(client, DATASET_ID, TABLE_ID, GCS_URI)
    
    print(f"\n🎉 Data pipeline completed successfully!")
    print(f"🔗 View in BigQuery: https://console.cloud.google.com/bigquery?project={PROJECT_ID}")