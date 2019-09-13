#!/usr/bin/env python

# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

"""
An example to show receiving events from an Event Hub partition.
"""
import os
import time
from datetime import datetime
from azure.eventhub import EventHubClient, Offset

PARTITION = "1"


total = 0
last_sn = -1
last_offset = "-1"
client = EventHubClient.from_connection_string(conn_str='Endpoint=sb://eh-1640764647.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=k1NekpViDxW/kMBLAGIAG5qAxtnItL/6tfypo5WTsVU=', eventhub='eh01')

consumer = client.add_receiver(consumer_group="$default", partition=PARTITION,
                                  offset=Offset(datetime(2019,9,13,15,8)), prefetch=5000)

client.run()
start_time = time.time()
batch = consumer.receive(timeout=5)
while batch:
    for event_data in batch:
        last_offset = event_data.offset
        last_sn = event_data.sequence_number
        print("Received: {}, {}".format(last_offset, last_sn))
        print(event_data.body_as_str())
        total += 1
    batch = consumer.receive(timeout=5)
print("Received {} messages in {} seconds".format(total, time.time() - start_time))
client.stop()