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
import sys
from datetime import datetime
from azure.eventhub import EventHubClient, Offset

TOTAL = 0

client = EventHubClient.from_connection_string(conn_str=sys.argv[1], eventhub=sys.argv[2])
consumer0 = client.add_receiver(consumer_group="$default", partition="0",
                                  offset=Offset(datetime.strptime(sys.argv[3], "%d/%m/%Y %H:%M:%S")), prefetch=5000)
consumer1 = client.add_receiver(consumer_group="$default", partition="1",
                                  offset=Offset(datetime.strptime(sys.argv[3], "%d/%m/%Y %H:%M:%S")), prefetch=5000)

client.run()
try:
    start_time = time.time()
    batch = consumer0.receive(timeout=5)
    while batch:
        for event_data in batch:
            last_offset = event_data.offset
            last_sn = event_data.sequence_number
            print("Received: {}, {}".format(last_offset, last_sn))
            print(event_data.body_as_str())
            TOTAL += 1
        batch = consumer0.receive(timeout=5)
    print("consumer0 on Partition 0:")
    print("Received {} messages in {} seconds".format(TOTAL, time.time() - start_time))

    start_time = time.time()
    batch = consumer1.receive(timeout=5)
    while batch:
        for event_data in batch:
            last_offset = event_data.offset
            last_sn = event_data.sequence_number
            print("Received: {}, {}".format(last_offset, last_sn))
            print(event_data.body_as_str())
            TOTAL += 1
        batch = consumer1.receive(timeout=5)
    print("consumer1 on Partition 1:")
    print("Received {} messages in {} seconds".format(TOTAL, time.time() - start_time))
    client.stop()
except:
    client.stop()
