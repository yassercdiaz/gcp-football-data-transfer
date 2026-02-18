"""
Script to upload CSV files to Google Cloud Storage
Author: Yasser Cristancho Diaz
Date: 2026-02-18
"""

from google.cloud import storage
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Configuration from .env
PROJECT_ID = os.getenv("PROJECT_ID")
BUCKET_NAME = os.getenv("BUCKET_NAME")
LOCAL_FILE_PATH = os.getenv("LOCAL_DATA_PATH")
GCS_DESTINATION = "raw/clubs.csv"

def upload_to_gcs(bucket_name, source_file, destination_blob):
    """
    Upload a local file to Google Cloud Storage
    
    Args:
        bucket_name: Name of the GCS bucket
        source_file: Local file path
        destination_blob: Destination path in GCS
    """
    
    # Initialize Storage client
    storage_client = storage.Client(project=PROJECT_ID)
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob)
    
    # Upload file
    print(f"📤 Uploading {source_file} to gs://{bucket_name}/{destination_blob}...")
    blob.upload_from_filename(source_file)
    print(f"✅ File uploaded successfully!")
    print(f"🔗 URL: gs://{bucket_name}/{destination_blob}")

if __name__ == "__main__":
    # Validate environment variables
    if not all([PROJECT_ID, BUCKET_NAME, LOCAL_FILE_PATH]):
        print("❌ Error: Missing environment variables. Check your .env file")
        exit(1)
    
    # Check if file exists
    if not os.path.exists(LOCAL_FILE_PATH):
        print(f"❌ Error: File not found {LOCAL_FILE_PATH}")
        exit(1)
    
    # Upload file
    upload_to_gcs(BUCKET_NAME, LOCAL_FILE_PATH, GCS_DESTINATION)