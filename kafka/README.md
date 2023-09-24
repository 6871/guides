# Kafka Example

Docker Compose configuration to download, install and run Kafka and Zookeeper 
services with example Python producer and consumer services.

# Configuration Files

| File                                     | Description                                                                                                           |
|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| [compose.yaml](compose.yaml)             | Docker Compose file that runs the example services                                                                    |
| [Dockerfile](Dockerfile)                 | Dockerfile for running Kafka and Zookeeper; this installs Kafka from apache.org (by running [install.sh](install.sh)) |
| [DockerfileDevEnv](DockerfileDevEnv)     | Dockerfile for running examples; this installs Python, a Python virtual environment and OpenJDK                       |
| [install.sh](install.sh)                 | Install helper script that downloads, verifies and installs Kafka from apache.org                                     |
| [python/producer.py](python/producer.py) | An example Kafka producer                                                                                             |
| [python/consumer.py](python/consumer.py) | An example Kafka consumer                                                                                             |

The [compose.yaml](compose.yaml) file runs the following services:

| Service   | Description                 |
|-----------|-----------------------------|
| kafka     | Kafka server                |
| zookeeper | Zookeeper service for Kafka |
| producer  | Example Kafka producer      |
| consumer  | Example Kafka consumer      |

# How To Run

## Docker Compose

```bash 
docker compose up --detach \
&& docker compose logs --follow
```

```bash
docker compose down
```

## Development Image

```bash
# Builds image tagged dev-env:0.0.0
docker build --tag dev-env:0.0.0 --file ./DockerfileDevEnv .
```

```bash
# Uses image tagged dev-env:0.0.0
# Mounts python directory at /workdir/python
# Uses kafka_kafka-network that's available when running compose.yaml
docker \
  run \
    --name kafka-dev-env \
    --rm --tty --interactive \
    --mount "type=bind,source=${PWD}/python,target=/workdir/python,readonly" \
    --entrypoint bash \
    --network kafka_kafka-network \
    dev-env:0.0.0
```
