# Azurite example

Use `docker compose` to run a local Azurite blob service and custom API that
generates a URL (with SAS token) that can be used to upload a file.

The following DNS configuration is used to map remote host names to localhost
(`*.local.6871.uk` maps to `127.0.0.1`):

* `api.example.local.6871.uk` resolves to `127.0.0.1`
* `azurite.example.local.6871.uk` resolves to `127.0.0.1`

⚠️ Use a domain you control: other services (e.g. `local.6871.uk` or `nip.io`)
can change and redirect traffic elsewhere.

The `azurite` service requires the following settings in [compose.yml](compose.yml):

1. `hostname: azurite.example.local.6871.uk`
2. `--disableProductStyleUrl` ([disable-production-style-url](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio%2Cblob-storage#disable-production-style-url))

# Example overview

```
+---------------+           +----------------------------+
|               |           |       docker compose       |
|     client    |           +------------------+---------+
|               |           |       api        |         |
+---------------+           +------------------+ azurite |
| file_tx_rx.py |           | /get-new-sas-url |         |                                                        
+---------------+           +------------------+---------+
        |                            |              |
        |------------ 1 ------------>|              |
        |                            |----- 2 ----->|
        |                            |<---- 3 ------|
        |<----------- 4 -------------|              |
        |-------------------- 5 ------------------->|
        |                            |              |

1. POST to api.example.local.6871.uk:5001/get-new-sas-url to request file upload URL
2. API requests SAS token from storage service
3. API gets SAS token from storage service
4. API returns URL with SAS token that client can use to send a file
5. Client uses URL to send file to blob storage (azurite.example.local.6871.uk:10000)
```

# How to run

From this directory ([azure/azurite](../../azure/azurite)):

1. Start the compose services:

    ```bash
    docker compose --env-file azurite.env up
    ```

2. Create a Python virtual environment for the example client script:

    ```bash
    python3 -m venv .venv-azureite-client
    source .venv-azureite-client/bin/activate
    pip3 install --requirement client/requirements.txt
    ```

3. Run the example client script ([file_tx_rx.py](client/file_tx_rx.py)):
 
    ```bash
    export EXAMPLE_API_HOST='http://api.example.local.6871.uk:5001' 
    
    ./client/file_tx_rx.py \
      --source-filename client/test_file.txt \
      --target-filename target.txt \
      --target-container foo \
      --download-filename tmp.txt
    ```

To stop: 

```bash
docker compose down
```

To remove all local Docker images, volumes and build cache:

```bash
docker rmi $(docker images --quiet) 
docker volume rm azurite_azurite_data
docker system prune -a --volumes
```
