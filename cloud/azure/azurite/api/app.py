import os
from flask import Flask, jsonify, request
from azure.storage.blob import BlobServiceClient, generate_blob_sas, BlobSasPermissions
from azure.core.exceptions import ResourceExistsError
from datetime import datetime, timezone, timedelta
import logging

app = Flask(__name__)

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

AZURE_BLOB_HOST = os.environ["EXAMPLE_AZURE_BLOB_HOST"]  # e.g. http://azurite.example.local.6871.uk:10000
ACCOUNT_NAME = os.environ["EXAMPLE_AZURE_ACCOUNT_NAME"]  # e.g. devstoreaccount1
ACCOUNT_KEY = os.environ["EXAMPLE_AZURE_ACCOUNT_KEY"]  # e.g. Current Azurite example has an 88 character string

logger.info("AZURE_BLOB_HOST: %s", AZURE_BLOB_HOST)
logger.info("ACCOUNT_NAME: %s", ACCOUNT_NAME)
logger.info("ACCOUNT_KEY: %s", ACCOUNT_KEY)

connection_string = (
    f"DefaultEndpointsProtocol=http;AccountName={ACCOUNT_NAME};"
    f"AccountKey={ACCOUNT_KEY};BlobEndpoint={AZURE_BLOB_HOST}/{ACCOUNT_NAME};"
)

logger.info("connection_string: %s", connection_string)
blob_service_client = BlobServiceClient.from_connection_string(connection_string)


@app.route('/')
def home():
    return 'API is running'


@app.route('/get-new-sas-url', methods=['POST'])
def get_new_sas_url():
    logger.debug("Received request to generate SAS URL")
    container_name = request.json.get('container_name')
    blob_name = request.json.get('blob_name')

    container_client = blob_service_client.get_container_client(container_name)
    try:
        logger.debug(f"Creating container: {container_name}")
        container_client.create_container()
        logger.info(f"Container created: {container_name}")
    except ResourceExistsError:
        logger.info(f"Container already exists: {container_name}")
    except Exception as e:
        logger.error(f"Container creation error: {e}")
        return jsonify({"error": str(e)}), 500

    logger.debug(f"Generating SAS token for blob: {blob_name} in container: {container_name}")
    try:
        sas_token = generate_blob_sas(
            account_name=ACCOUNT_NAME,
            container_name=container_name,
            blob_name=blob_name,
            account_key=ACCOUNT_KEY,
            permission=BlobSasPermissions(read=True, write=True),
            expiry=datetime.now(timezone.utc) + timedelta(hours=1)
        )
    except Exception as e:
        logger.error(f"SAS token generation error: {e}")
        return jsonify({"error": str(e)}), 500

    url = f"{AZURE_BLOB_HOST}/{ACCOUNT_NAME}/{container_name}/{blob_name}?{sas_token}"
    logger.debug(f"SAS URL generated: {url}")
    return jsonify({"url": url})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
