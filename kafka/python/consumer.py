#!/usr/bin/env python3
from confluent_kafka import Consumer
from datetime import datetime

print(f'consumer.py: started at: {datetime.now().isoformat()}')

consumer = Consumer(
    {
        'bootstrap.servers': 'kafka:9092',  # comma separated host:port list
        'group.id': 'baz-group',
        'auto.offset.reset': 'earliest'     # 'latest', 'earliest', 'none'
    }
)

consumer.subscribe(['foo-topic'])

try:
    while True:
        message = consumer.poll(1.0)

        if message is None:
            print('consumer.py: no message, will poll again')
        elif message.error():
            print(f'consumer.py: error: {message.error()}')
            break
        else:
            print(
                f'consumer.py: message: {message.value()}'
                f' message.topic={message.topic()}'
                f' message.partition={message.partition()}'
                f' message.offset={message.offset()}'
                f' message.headers={message.headers()}'
            )
finally:
    consumer.close()

print(f'consumer.py: terminating at: {datetime.now().isoformat()}')
