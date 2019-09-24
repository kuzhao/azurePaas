import java.util._
import scala.collection.JavaConverters._
import java.util.concurrent._
import java.util.Calendar

import org.apache.spark._
import org.apache.spark.streaming._
import org.apache.spark.eventhubs.ConnectionStringBuilder

// Event hub configurations
// Replace values below with yours        
var dT = Calendar.getInstance()
val eventHubName = "<HubName>"
val eventHubNSConnStr = "<NamespaceConnStr>"
val connStr = ConnectionStringBuilder(eventHubNSConnStr).setEventHubName(eventHubName).build 

import com.microsoft.azure.eventhubs._
val pool = Executors.newScheduledThreadPool(4)
val ehClient = EventHubClient.createSync(connStr.toString(), pool)


def sendEvent(message: String) = {
      val messageData = EventData.create(message.getBytes("UTF-8"))
      ehClient.sendSync(messageData)
      println("Sent event: " + message)
}

for (i <- 1 to 100) {
  var currentSec = dT.get(Calendar.SECOND)
  var currentMinute = dT.get(Calendar.MINUTE)
  var currentHour = dT.get(Calendar.HOUR_OF_DAY)
  sendEvent("Msg #" + i.toString + " sent at " + currentHour + ":" + currentMinute + ":" + currentSec)
}

// Closing connection to the Event Hub
eventHubClient.get().close()