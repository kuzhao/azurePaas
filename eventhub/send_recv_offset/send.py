#!/usr/bin/env python

# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

"""
An example to show sending individual events to an Event Hub partition.
Although this works, sending events in batches will get better performance.
See 'send_list_of_event_data.py' and 'send_event_data_batch.py' for an example of batching.
"""

# pylint: disable=C0111

import time
import os
import sys
from datetime import datetime
from azure.eventhub import EventHubClient, EventData


client = EventHubClient.from_connection_string(conn_str=sys.argv[1], eventhub=sys.argv[2])
producer = client.add_sender()
start_time = time.time()
client.run()
for i in range(100):
    ed = EventData("msg #"+ str(i) +" at "+ str(datetime.now()))
    print("Sending message: {}".format(i))
    producer.send(ed)
print("Send 100 messages in {} seconds".format(time.time() - start_time))
client.stop()
