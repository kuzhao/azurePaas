import os
import sys

from random import randrange
from azure.servicebus import ServiceBusClient
from azure.servicebus import Message
from azure.servicebus.common.constants import ReceiveSettleMode

def get_live_servicebus_config():
    config = {}
    config['hostname'] = os.environ['SERVICE_BUS_HOSTNAME']
    config['key_name'] = os.environ['SERVICE_BUS_SAS_POLICY']
    config['access_key'] = os.environ['SERVICE_BUS_SAS_KEY']
    config['queue_name'] = os.environ['QUEUE_NAME']
    return config

def queue_rcv(sb_config, queue):

    client = ServiceBusClient(
        service_namespace=sb_config['hostname'],
        shared_access_key_name=sb_config['key_name'],
        shared_access_key_value=sb_config['access_key'],
        debug=False)

    queue_client = client.get_queue(queue)
    with queue_client.get_receiver(mode=ReceiveSettleMode.PeekLock, prefetch=10) as receiver:
        # Receive messages as a continuous generator
        for message in receiver:
            print("Message: {}".format(message))
            print("Sequence number: {}".format(message.sequence_number))
            message.complete()


if __name__ == '__main__':
    live_config = get_live_servicebus_config()
    queue_name = live_config['queue_name']
    print("Created queue {}".format(queue_name))
    try:
        queue_rcv(live_config, queue_name)
    except:
        print("Rcv Error!")
