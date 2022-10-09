import os
import sys
from time import sleep

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
    config['pub_name'] = os.environ['PUBLISHER']
    return config

def queue_sender(sb_config, queue):

    client = ServiceBusClient(
        service_namespace=sb_config['hostname'],
        shared_access_key_name=sb_config['key_name'],
        shared_access_key_value=sb_config['access_key'],
        debug=False)

    queue_client = client.get_queue(queue)
    with queue_client.get_sender() as sender:
        while True:
            for i in range(100):
                message = Message("Publishing from {}: Sample message no. {}".format(live_config['pub_name'],i))
                sender.send(message)
            sleep(randrange(9))


if __name__ == '__main__':
    live_config = get_live_servicebus_config()
    queue_name = live_config['queue_name']
    print("Created queue {}".format(queue_name))
    try:
        queue_sender(live_config, queue_name)
    except:
        print("Send Error!")
