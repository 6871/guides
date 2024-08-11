#!/usr/bin/env python3
import argparse
import os
import requests
from azure.storage.blob import BlobClient

API_HOST = os.environ["EXAMPLE_API_HOST"]  # e.g. "http://api.example.local.6871.uk:5001"
API_ENDPOINT_GET_NEW_SAS_URL = f"{API_HOST}/get-new-sas-url"
print(f"API_ENDPOINT_GET_NEW_SAS_URL: {API_ENDPOINT_GET_NEW_SAS_URL}")

def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source-filename", help="The file to send to blob storage", dest="source_filename", required=True
    )
    parser.add_argument("--target-container", help="The target blob storage container", dest="target_container", required=True)
    parser.add_argument(
        "--target-filename",
        help="Name of file in storage back-end",
        dest="target_filename",
        required=True,
    )
    parser.add_argument(
        "--download-filename",
        help="Name of file to save test download to",
        dest="download_filename",
        required=True
    )
    return parser.parse_args()


args: argparse.Namespace = get_args()

if os.path.exists(args.download_filename):
    raise FileExistsError(f"Can't test downloading uploaded file to {args.download_filename} as this already exists")

# 1. Get the SAS URL
data = {
    "container_name": args.target_container,  # Container to save to in blob storage
    "blob_name": args.target_filename  # Name to give file in blob storage
}

response = requests.post(API_ENDPOINT_GET_NEW_SAS_URL, json=data)
response.raise_for_status()
sas_url = response.json().get("url")
print(f"sas_url={sas_url}")

# 2. Upload a file using the SAS URL
print(f"args.source_filename  : {args.source_filename}")
print(f"args.target_filename  : {args.target_filename}")
print(f"args.target_container : {args.target_container}")
blob_client = BlobClient.from_blob_url(sas_url)
with open(args.source_filename, "rb") as data:
    blob_client.upload_blob(data, overwrite=True)
print(f"upload_blob complete for: {args.source_filename}")

# 3. Download the file using the SAS URL
with open(args.download_filename, "wb") as download_file:
    download_file.write(blob_client.download_blob().readall())
print(f"Downloaded: '{args.download_filename}")
