import org.apache.spark.eventhubs._
import java.time._
// Event hub configurations
// Replace values below with yours  
val eventHubName = "<HubName>"
val eventHubNSConnStr = "<NamespaceConnStr>"
val connStr = ConnectionStringBuilder(eventHubNSConnStr).setEventHubName(eventHubName).build
val ehpos = EventPosition.fromEnqueuedTime(Instant.parse("2019-09-23T04:40:55.645Z"))

val customEventhubParameters = EventHubsConf(connStr).setMaxEventsPerTrigger(5).setStartingPosition(ehpos)
val incomingStream = spark.readStream.format("eventhubs").options(customEventhubParameters.toMap).load()
//incomingStream.printSchema    

import org.apache.spark.sql.types._
import org.apache.spark.sql.functions._

// Event Hub message format is JSON and contains "body" field
// Body is binary, so you cast it to string to see the actual content of the message
val messages = incomingStream.withColumn("Offset", $"offset".cast(LongType)).withColumn("Time (readable)", $"enqueuedTime".cast(TimestampType)).withColumn("Timestamp", $"enqueuedTime".cast(LongType)).withColumn("Body", $"body".cast(StringType)).select("Offset", "Time (readable)", "Timestamp", "Body")

messages.printSchema

messages.writeStream.outputMode("append").format("console").option("truncate", false).start().awaitTermination()