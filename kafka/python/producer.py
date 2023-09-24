#!/usr/bin/env python3
import argparse
from confluent_kafka import Producer
from datetime import datetime
import random

# Parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument(
    '--max-random-message-count',
    dest='max_random_message_count',
    type=int,
    default=1
)
args = parser.parse_args()

# Producer configuration settings:
# bootstrap.servers : broker list for producer to establish cluster connection
producer = Producer(
    {
        'bootstrap.servers': 'kafka:9092'  # comma separated host:port list
    }
)


# Method for Kafka's send process to call back to with send outcomes
def message_send_callback_handler(error, message):
    if error is not None:
        print(f'Error: {format(error)}')
    else:
        print(
            f'producer.py: message_send_callback_handler:'
            f' message.topic={message.topic()}'
            f' message.partition={message.partition()}'
            f' message.offset={message.offset()}'
            f' message.headers={message.headers()}'
        )


# Send a random number of messages
message_count = random.randint(1, args.max_random_message_count)
for i in range(message_count):
    print(f'producer.py: sending message {i + 1}/{message_count}')
    t = datetime.now().isoformat()
    producer.produce(
        topic='foo-topic',
        key='bar-key',
        value=f'Hello, World {i + 1}! The time according to Kafka is: {t}',
        callback=message_send_callback_handler
    )

# Ensure graceful shutdown before program exit
producer.flush()
