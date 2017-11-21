package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._
import com.opendatagroup.fastscore.assets.builders._

import com.opendatagroup.fastscore.assets.serializers.StreamSerializer._
import io.circe.parser._
import io.circe.syntax._

import java.io.{File, PrintWriter}
import scala.io.Source

// Transport
case object StreamTransportType extends Enumeration {
    val http = Value("HTTP")
    val kafka = Value("Kafka")
    val rest = Value("REST")
    val file = Value("file")
    val odbc = Value("ODBC")
    val tcp = Value("TCP")
    val udp = Value("UDP")
    val exec = Value("exec")
    val inline = Value("inline")
    val discard = Value("discard")
}

sealed trait StreamTransport

case class StreamTransportHTTP(
    url: String
) extends StreamTransport

case class StreamTransportKafka(
    bootstrapServers: List[String],
    topic: String,
    partition: Option[Int] = Some(0),
    maxWaitTime: Option[Int] = Some(0x7fffff)
) extends StreamTransport

case object StreamTransportRESTMode extends Enumeration {
    val simple = Value("simple")
    val chunked = Value("chunked")
}

case class StreamTransportREST(
    mode: StreamTransportRESTMode.Value = StreamTransportRESTMode.simple
) extends StreamTransport

case class StreamTransportFile(
    path: String
) extends StreamTransport

case class StreamTransportODBC(
    connectionString: String,
    selectQuery: String,
    insertIntoTable: String,
    outputFields: Option[List[String]],
    timeout: Option[Int] = None
) extends StreamTransport

case class StreamTransportTCP(
    host: String,
    port: Int
) extends StreamTransport

case class StreamTransportUDP(
    bindTo: String = "0.0.0.0",
    port: Int
) extends StreamTransport

case class StreamTransportExec(
    run: String
) extends StreamTransport

case class StreamTransportInline(
    data: Option[Either[String, List[String]]] = None,
    // base64
    dataBinary: Option[Either[String, List[String]]] = None
) extends StreamTransport

case object StreamTransportDiscard extends StreamTransport

// Envelope
case object StreamEnvelopeType extends Enumeration {
    val delimited = Value("delimited")
    val fixed = Value("fixed")
    val ocfBlock = Value("ocf-block")
}

sealed trait StreamEnvelope

case class StreamEnvelopeDelimited(
    separator: String
) extends StreamEnvelope

case class StreamEnvelopeFixed(
    size: Int
) extends StreamEnvelope

case class StreamEnvelopeOcfBlock(
    // If syncMarker omitted, skipHeader must be false
    syncMarker: Option[String] = None,
    skipHeader: Boolean = false
) extends StreamEnvelope

// Encoding
case object StreamEncoding extends Enumeration {
    val utf8 = Value("utf-8")
    val json = Value("json")
    val avroBinary = Value("avro-binary")
    val soapRpc = Value("soap-rpc")
}

// Schema
case class StreamSchemaRef(
    ref: String
)

// Batching
case object StreamBatchingMode extends Enumeration {
    val explicit = Value("explicit")
    val normal = Value("normal")
}

case class StreamBatching(
    watermark: Int,
    nagleTime: Int
)

case object KafkaSkipToRecord extends Enumeration {
    val latest = Value("latest")
    val earliest = Value("earliest")
}

object Stream {
    def fromFile(path: String): Stream = {
        val source = Source.fromFile(path).getLines.mkString
        parse(source) match {
            case Right(j) =>
                j.as[Stream] match {
                    case Right(s) => s
                    case Left(_) => throw FastScoreError("Invalid stream spec")
                }
            case Left(_) => throw FastScoreError("Malformed stream JSON")
        }
    }
}

case class Stream(
    version: String = "1.2",
    description: Option[String] = None,
    transport: StreamTransport,
    loop: Boolean = false,
    skipTo: Option[Int] = None,
    skipToRecord: Option[Either[Int, KafkaSkipToRecord.Value]] = None,
    envelope: Option[StreamEnvelope] = None,
    encoding: Option[StreamEncoding.Value] = None,
    schema: Option[Either[String, StreamSchemaRef]] = None,
    batching: Either[StreamBatchingMode.Value, StreamBatching] = Left(StreamBatchingMode.normal),
    lingerTime: Int = 3000
) extends StreamJSONSerializer

trait StreamJSONSerializer {
    val version: String
    val description: Option[String]
    val transport: StreamTransport
    val loop: Boolean
    val skipTo: Option[Int]
    val skipToRecord: Option[Either[Int, KafkaSkipToRecord.Value]]
    val envelope: Option[StreamEnvelope]
    val encoding: Option[StreamEncoding.Value]
    val schema: Option[Either[String, StreamSchemaRef]]
    val batching: Either[StreamBatchingMode.Value, StreamBatching]
    val lingerTime: Int

    override def toString(): String = {
        Stream(version, description, transport, loop, skipTo, skipToRecord, envelope, encoding, schema, batching, lingerTime).asJson.spaces4
    }

    def toFile(path: String): Unit = {
        val writer = new PrintWriter(new File(path))
        writer.write(Stream(version, description, transport, loop, skipTo, skipToRecord, envelope, encoding, schema, batching, lingerTime).toString)
        writer.close
    }

    def toBuilder(): StreamBuilder = {
        new StreamBuilder(
            transport match {
                case t: StreamTransportHTTP => Some(new StreamTransportHTTPBuilder(Some(t.url))(_))
                case t: StreamTransportUDP => Some(new StreamTransportUDPBuilder(t.bindTo, Some(t.port))(_))
                case t: StreamTransportTCP => Some(new StreamTransportTCPBuilder(Some(t.host), Some(t.port))(_))
                case t: StreamTransportREST => Some(new StreamTransportRESTBuilder(t.mode)(_))
                case t: StreamTransportKafka => Some(new StreamTransportKafkaBuilder(Some(t.bootstrapServers), Some(t.topic), t.partition, t.maxWaitTime)(_))
                case t: StreamTransportDiscard.type => Some(new StreamTransportDiscardBuilder()(_))
                case t: StreamTransportExec => Some(new StreamTransportExecBuilder(Some(t.run))(_))
                case t: StreamTransportFile => Some(new StreamTransportFileBuilder(Some(t.path))(_))
                case t: StreamTransportODBC => Some(new StreamTransportODBCBuilder(Some(t.connectionString), Some(t.selectQuery), Some(t.insertIntoTable), t.outputFields, t.timeout)(_))
                case t: StreamTransportInline => Some(new StreamTransportInlineBuilder(t.data, t.dataBinary)(_))
            },
            schema match {
                case Some(schema) => schema match {
                    case Left(schema) => Some(Left(schema))
                    case Right(schema) => Some(Right(new StreamSchemaRefBuilder(Some(schema.ref))(_)))
                }
                case None => None
            },
            batching match {
                case Left(batchingMode) => Some(Left(batchingMode))
                case Right(batching) => Some(Right(new StreamBatchingBuilder(Some(batching.watermark), Some(batching.nagleTime))(_)))
            },
            version,
            description,
            loop,
            skipTo,
            skipToRecord,
            envelope match {
                case Some(e) => e match {
                    case e: StreamEnvelopeDelimited => Some (new StreamEnvelopeDelimitedBuilder (e.separator) (_) )
                    case e: StreamEnvelopeFixed => Some (new StreamEnvelopeFixedBuilder (Some (e.size) ) (_) )
                    case e: StreamEnvelopeOcfBlock => Some (new StreamEnvelopeOcfBlockBuilder (e.syncMarker, e.skipHeader) (_) )
                }
                case None => None
            },
            encoding,
            lingerTime
        )
    }
}

sealed trait StreamMetaOps {
    val name: String
    val modelmanage: ModelManage

    def get(): Stream = {
        modelmanage.v1.streamGet(modelmanage.toString, name) match {
            case Some(source) =>
                parse(source.toString) match {
                    case Right(json) => json.as[Stream] match {
                        case Right(stream) => stream
                        case Left(_) => throw FastScoreError("Failed to parse stream")
                    }
                    case Left(_) => throw FastScoreError("Malformed stream JSON")
                }
            case None => throw FastScoreError("Stream not found")
        }
    }

    def delete(): Unit = {
        modelmanage.v1.streamDelete(modelmanage.toString, name)
    }
}

case class StreamMetadata(
    name: String,
    modelmanage: ModelManage
) extends StreamMetaOps with Asset[Stream]