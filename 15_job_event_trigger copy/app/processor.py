#!/usr/bin/env python

import os
import asyncio
from azure.servicebus import ServiceBusMessage
from azure.servicebus.aio import ServiceBusClient

CONNECTION_STR = os.environ['SERVICEBUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICEBUS_QUEUE_NAME"]


async def send_single_message(sender):
    message = ServiceBusMessage("My First Message")
    await sender.send_messages(message)

async def receive_single_message(receiver):
    messages = await receiver.receive_messages(max_message_count=1, max_wait_time=5)
    print(f"Received message: {str(messages[0])}")
    await receiver.complete_message(messages[0])

async def main():
    servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR)

    async with servicebus_client:
        sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)
        async with sender:
            await send_single_message(sender)

        receiver = servicebus_client.get_queue_receiver(queue_name=QUEUE_NAME)
        async with receiver:
            await receive_single_message(receiver)


asyncio.run(main())