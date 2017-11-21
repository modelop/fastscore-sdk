package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.serializers.PneumoMessageSerializer._
import com.opendatagroup.fastscore.util.{ FastScoreError, SSLVerify }

import com.ning.http.client._
import com.ning.http.client.websocket._

import scala.collection.mutable.{ ListBuffer => MutList }
import scala.collection.immutable.{ Stream => IStream }

import io.circe.parser._

class Pneumo(
    implicit val proxy: Proxy
) {
    private val pneumoExt = "/connect/1/notify"
    private val socketPath = s"${proxy.basePath.replace("https", "wss")}$pneumoExt"

    SSLVerify.disableSSLVerify

    private val c = new AsyncHttpClient()

    private val buffer = new Buffer[PneumoMessage]

    private class Buffer[A] extends Iterator[A] {
        private var buffer: MutList[A] = MutList.empty[A]
        private val MAX_BUFFER_SIZE = 128

        def put(v: A): Unit = {
            if (buffer.length == MAX_BUFFER_SIZE)
                buffer.remove(buffer.length)
            buffer += v
        }

        def flush(): Unit = this.buffer = MutList.empty[A]

        override def hasNext: Boolean = true
        override def next: A = {
            while (this.buffer.isEmpty)
                Thread.sleep(10)
            buffer.remove(0)
        }
    }

    private val socket = c.prepareGet("wss://127.0.0.1:8000/api/1/service/connect/1/notify")
        .execute(new WebSocketUpgradeHandler.Builder().addWebSocketListener(
            new WebSocketTextListener {
                override def onMessage(message: String): Unit = {
                    val json = parse(message).right.get
                    val pneumoMessage: PneumoMessage = json.hcursor.downField("type").as[String].right.get match {
                        case "health" => json.as[HealthMessage].right.get
                        case "log" => json.as[LogMessage].right.get
                        case "model-console" => json.as[ModelConsoleMessage].right.get
                        case "engine-state" => json.as[EngineStateMessage].right.get
                        case "engine-config" => json.as[EngineConfigMessage].right.get
                        case "sensor-report" => json.as[SensorReportMessage].right.get
                        case "model-error" => json.as[ModelErrorMessage].right.get
                        case messageType => throw FastScoreError(s"Unexpected Pneumo message type: $messageType")
                    }
                    buffer.put(pneumoMessage)
                }
                override def onError(t: Throwable): Unit = {}
                override def onClose(w: WebSocket): Unit = {}
                override def onOpen(w: WebSocket): Unit = {}
                override def onFragment(fragment: String, last: Boolean): Unit = {}
            }
        ).build).get

    def close(): Unit = socket.close()

    def flush(): Unit = buffer.flush()

    def recv(): PneumoMessage = buffer.next

    def stream(): IStream[PneumoMessage] = buffer.toStream
}