package com.opendatagroup.fastscore.assets.serializers

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.util._

import io.circe._
import io.circe.syntax._
import io.circe.generic.semiauto.deriveDecoder
import io.circe.Decoder

/** Stream Object Serializer/Deserializer
  *
  */
object StreamSerializer {
    implicit val encodeStreamBatching: Encoder[StreamBatching] = new Encoder[StreamBatching] {
        final def apply(a: StreamBatching): Json = Json.obj(
            ("Watermark", Json.fromInt(a.watermark)),
            ("NagleTime", Json.fromInt(a.nagleTime))
        )
    }

    implicit val decodeStreamBatching: Decoder[StreamBatching] = new Decoder[StreamBatching] {
        final def apply(a: HCursor): Decoder.Result[StreamBatching] =
            for {
                watermark <- a.downField("Watermark").as[Int]
                nagleTime <- a.downField("NagleTime").as[Int]
            } yield {
                StreamBatching(watermark, nagleTime)
            }
    }

    implicit val encodeStreamSchemaRef: Encoder[StreamSchemaRef] = new Encoder[StreamSchemaRef] {
        final def apply(a: StreamSchemaRef): Json = Json.obj(
            ("$ref", Json.fromString(a.ref))
        )
    }

    implicit val decodeStreamSchemaRef: Decoder[StreamSchemaRef] = new Decoder[StreamSchemaRef] {
        final def apply(a: HCursor): Decoder.Result[StreamSchemaRef] =
            for {
                ref <- a.downField("$ref").as[String]
            } yield {
                StreamSchemaRef(ref)
            }
    }

    implicit val encodeStreamEnvelopeDelimited: Encoder[StreamEnvelopeDelimited] = new Encoder[StreamEnvelopeDelimited] {
        final def apply(a: StreamEnvelopeDelimited): Json = Json.obj(
            ("Type", Json.fromString("delimited")),
            ("Separator", Json.fromString(a.separator))
        )
    }

    implicit val decodeStreamEnvelopeDelimited: Decoder[StreamEnvelopeDelimited] = new Decoder[StreamEnvelopeDelimited] {
        final def apply(a: HCursor): Decoder.Result[StreamEnvelopeDelimited] =
            for {
                separator <- a.downField("Separator").as[String]
            } yield {
                StreamEnvelopeDelimited(separator)
            }
    }

    implicit val encodeStreamEnvelopeFixed: Encoder[StreamEnvelopeFixed] = new Encoder[StreamEnvelopeFixed] {
        final def apply(a: StreamEnvelopeFixed): Json = Json.obj(
            ("Type", Json.fromString("fixed")),
            ("Size", Json.fromInt(a.size))
        )
    }

    implicit val decodeStreamEnvelopeFixed: Decoder[StreamEnvelopeFixed] = new Decoder[StreamEnvelopeFixed] {
        final def apply(a: HCursor): Decoder.Result[StreamEnvelopeFixed] =
            for {
                size <- a.downField("Size").as[Int]
            } yield {
                StreamEnvelopeFixed(size)
            }
    }

    implicit val encodeStreamEnvelopeOcfBlock: Encoder[StreamEnvelopeOcfBlock] = new Encoder[StreamEnvelopeOcfBlock] {
        final def apply(a: StreamEnvelopeOcfBlock): Json = {
            var envelope =  Json.obj(
                ("Type", Json.fromString("ocf-block")),
                ("SkipHeader", Json.fromBoolean(a.skipHeader))
            )

            val syncMarker: Option[Json] = a.syncMarker match {
                case Some(s) => Some(Json.obj(("SyncMarker", Json.fromString(s))))
                case None => None
            }

            envelope = if (syncMarker.isDefined) envelope.deepMerge(syncMarker.get) else envelope

            envelope
        }
    }

    implicit val decodeStreamEnvelopeOcfBlock: Decoder[StreamEnvelopeOcfBlock] = new Decoder[StreamEnvelopeOcfBlock] {
        final def apply(a: HCursor): Decoder.Result[StreamEnvelopeOcfBlock] =
            for {
                syncMarker <- a.downField("SyncMarker").as[Option[String]]
                skipHeader <- a.downField("SkipHeader").as[Boolean]
            } yield {
                if (syncMarker.isEmpty && skipHeader)
                    throw FastScoreError("Illegal OCF Envelope definition")
                StreamEnvelopeOcfBlock(syncMarker, skipHeader)
            }
    }

    implicit val encodeStreamTransportHTTP: Encoder[StreamTransportHTTP] = new Encoder[StreamTransportHTTP] {
        final def apply(a: StreamTransportHTTP): Json = Json.obj(
            ("Type", Json.fromString("HTTP")),
            ("Url", Json.fromString(a.url))
        )
    }

    implicit val decodeStreamTransportHTTP: Decoder[StreamTransportHTTP] = new Decoder[StreamTransportHTTP] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportHTTP] =
            for {
                url <- a.downField("Url").as[String]
            } yield {
                StreamTransportHTTP(url)
            }
    }

    implicit val encodeStreamTransportTCP: Encoder[StreamTransportTCP] = new Encoder[StreamTransportTCP] {
        final def apply(a: StreamTransportTCP): Json = Json.obj(
            ("Type", Json.fromString("TCP")),
            ("Host", Json.fromString(a.host)),
            ("Port", Json.fromInt(a.port))
        )
    }

    implicit val decodeStreamTransportTCP: Decoder[StreamTransportTCP] = new Decoder[StreamTransportTCP] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportTCP] =
            for {
                host <- a.downField("Host").as[String]
                port <- a.downField("Port").as[Int]
            } yield {
                StreamTransportTCP(host, port)
            }
    }

    implicit val encodeStreamTransportUDP: Encoder[StreamTransportUDP] = new Encoder[StreamTransportUDP] {
        final def apply(a: StreamTransportUDP): Json = Json.obj(
            ("Type", Json.fromString("UDP")),
            ("BindTo", Json.fromString(a.bindTo)),
            ("Port", Json.fromInt(a.port))
        )
    }

    implicit val decodeStreamTransportUDP: Decoder[StreamTransportUDP] = new Decoder[StreamTransportUDP] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportUDP] =
            for {
                bindTo <- a.downField("BindTo").as[String]
                port <- a.downField("Port").as[Int]
            } yield {
                StreamTransportUDP(bindTo, port)
            }
    }

    implicit val encodeStreamTransportKafka: Encoder[StreamTransportKafka] = new Encoder[StreamTransportKafka] {
        final def apply(a: StreamTransportKafka): Json = {
            var transport = Json.obj(
                ("Type", Json.fromString("Kafka")),
                ("BootstrapServers", a.bootstrapServers.asJson),
                ("Topic", Json.fromString(a.topic))
            )

            val partition: Option[Json] = a.partition match {
                case Some(p) => Some(Json.obj(("Partition", Json.fromInt(a.partition.get))))
                case None => None
            }

            val maxWaitTime: Option[Json] = a.maxWaitTime match {
                case Some(p) => Some(Json.obj(("MaxWaitTime", Json.fromInt(a.maxWaitTime.get))))
                case None => None
            }

            transport = if (partition.isDefined) transport.deepMerge(partition.get) else transport

            transport = if (maxWaitTime.isDefined) transport.deepMerge(maxWaitTime.get) else transport

            transport
        }
    }

    implicit val decodeStreamTransportKafka: Decoder[StreamTransportKafka] = new Decoder[StreamTransportKafka] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportKafka] =
            for {
                bootstrapServers <- a.downField("BootstrapServers").as[List[String]]
                topic <- a.downField("Topic").as[String]
                partitionOpt <- a.downField("Partition").as[Option[Int]]
                maxWaitTimeOpt <- a.downField("MaxWaitTime").as[Option[Int]]
            } yield {
                val partition = if (partitionOpt.isDefined) partitionOpt else Some(0)
                val maxWaitTime = if (maxWaitTimeOpt.isDefined) maxWaitTimeOpt else Some(0x7fffff)
                StreamTransportKafka(bootstrapServers, topic, partition, maxWaitTime)
            }
    }

    implicit val encodeStreamTransportFile: Encoder[StreamTransportFile] = new Encoder[StreamTransportFile] {
        final def apply(a: StreamTransportFile): Json = Json.obj(
            ("Type", Json.fromString("file")),
            ("Path", Json.fromString(a.path))
        )
    }

    implicit val decodeStreamTransportFile: Decoder[StreamTransportFile] = new Decoder[StreamTransportFile] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportFile] =
            for {
                path <- a.downField("Path").as[String]
            } yield {
                StreamTransportFile(path)
            }
    }

    implicit val encodeStreamTransportExec: Encoder[StreamTransportExec] = new Encoder[StreamTransportExec] {
        final def apply(a: StreamTransportExec): Json = Json.obj(
            ("Type", Json.fromString("Exec")),
            ("Run", Json.fromString(a.run))
        )
    }

    implicit val decodeStreamTransportExec: Decoder[StreamTransportExec] = new Decoder[StreamTransportExec] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportExec] =
            for {
                run <- a.downField("Run").as[String]
            } yield {
                StreamTransportExec(run)
            }
    }

    implicit val encodeStreamTransportInline: Encoder[StreamTransportInline] = new Encoder[StreamTransportInline] {
        final def apply(a: StreamTransportInline): Json = {
            var transport = Json.obj(
                ("Type", Json.fromString("Inline"))
            )

            val data: Option[Json] = a.data match {
                case Some(Left(d)) => Some(Json.obj(("Data", Json.fromString(d))))
                case Some(Right(d)) => Some(Json.obj(("Data", d.asJson)))
                case None => None
            }

            val dataBinary: Option[Json] = a.data match {
                case Some(Left(d)) => Some(Json.obj(("DataBinary", Json.fromString(d))))
                case Some(Right(d)) => Some(Json.obj(("DataBinary", d.asJson)))
                case None => None
            }

            transport = if (data.isDefined) transport.deepMerge(data.get) else transport

            transport = if (dataBinary.isDefined) transport.deepMerge(dataBinary.get) else transport

            transport
        }
    }

    implicit val decodeStreamTransportInline: Decoder[StreamTransportInline] = new Decoder[StreamTransportInline] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportInline] = {
            val data = a.downField("Data")
            val dataBinary = a.downField("DataBinary")
            (data.succeeded, dataBinary.succeeded) match {
                case (true, false) =>
                    a.downField("Data").as[String].right.toOption match {
                        case Some(d) =>
                            Right[DecodingFailure, StreamTransportInline](
                                StreamTransportInline(data = Some(Left(d)))   
                            )
                        case None =>
                            Right[DecodingFailure, StreamTransportInline](
                                StreamTransportInline(data = Some(Right(a.downField("Data").as[List[String]].right.get)))
                            )
                    }
                case (false, true) =>
                    a.downField("DataBinary").as[String].right.toOption match {
                        case Some(d) =>
                            Right[DecodingFailure, StreamTransportInline](
                                StreamTransportInline(dataBinary = Some(Left(d)))   
                            )
                        case None =>
                            Right[DecodingFailure, StreamTransportInline](
                                StreamTransportInline(data = Some(Right(a.downField("Data").as[List[String]].right.get)))
                            )
                    }
                case _ => throw FastScoreError("Malformed inline transport spec")
            }
        }
    }

    implicit val encodeStreamTransportREST: Encoder[StreamTransportREST] = new Encoder[StreamTransportREST] {
        final def apply(a: StreamTransportREST): Json = Json.obj(
            ("Type", Json.fromString("REST")),
            ("Mode", Json.fromString(a.mode.toString))
        )
    }

    implicit val decodeStreamTransportREST: Decoder[StreamTransportREST] = new Decoder[StreamTransportREST] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportREST] =
            for {
                mode <- a.downField("Mode").as[String]
            } yield {
                StreamTransportREST(
                    StreamTransportRESTMode.withName(mode)
                )
            }
    }

    implicit val encodeStreamTransportODBC: Encoder[StreamTransportODBC] = new Encoder[StreamTransportODBC] {
        final def apply(a: StreamTransportODBC): Json = {
            var transport = Json.obj(
                ("Type", Json.fromString("ODBC")),
                ("ConnectionString", Json.fromString(a.connectionString)),
                ("SelectQuery", Json.fromString(a.selectQuery)),
                ("InsertIntoTable", Json.fromString(a.insertIntoTable))
            )

            val outputFields: Option[Json] = a.outputFields match {
                case Some(o) => Some(Json.obj(("OutputFields", o.asJson)))
                case None => None
            }

            val timeout: Option[Json] = a.timeout match {
                case Some(t) => Some(Json.obj(("Timeout", Json.fromInt(t))))
                case None => None
            }

            transport = if (outputFields.isDefined) transport.deepMerge(outputFields.get) else transport

            transport = if (timeout.isDefined) transport.deepMerge(timeout.get) else transport

            transport
        }
    }

    implicit val decodeStreamTransportODBC: Decoder[StreamTransportODBC] = new Decoder[StreamTransportODBC] {
        final def apply(a: HCursor): Decoder.Result[StreamTransportODBC] =
            for {
                connectionString <- a.downField("ConnectionString").as[String]
                selectQuery <- a.downField("SelectQuery").as[String]
                insertIntoTable <- a.downField("InsertIntoTable").as[String]
                outputFields <- a.downField("OutputFields").as[Option[List[String]]]
                timeout <- a.downField("Timeout").as[Option[Int]]
            } yield {
                StreamTransportODBC(connectionString, selectQuery, insertIntoTable, outputFields, timeout)
            }
    }

    implicit val decodeStreamTransport: Decoder[StreamTransport] = new Decoder[StreamTransport] {
        final def apply(a: HCursor): Decoder.Result[StreamTransport] =
            for {
                _type <- a.downField("Type").as[String]
            } yield {
                StreamTransportType.withName(_type) match {
                    case StreamTransportType.http => a.as[StreamTransportHTTP].right.get
                    case StreamTransportType.kafka => a.as[StreamTransportKafka].right.get
                    case StreamTransportType.rest => a.as[StreamTransportREST].right.get
                    case StreamTransportType.file => a.as[StreamTransportFile].right.get
                    case StreamTransportType.odbc => a.as[StreamTransportODBC].right.get
                    case StreamTransportType.tcp => a.as[StreamTransportTCP].right.get
                    case StreamTransportType.udp => a.as[StreamTransportUDP].right.get
                    case StreamTransportType.exec => a.as[StreamTransportExec].right.get
                    case StreamTransportType.inline => a.as[StreamTransportInline].right.get
                    case StreamTransportType.discard => StreamTransportDiscard
                }
            }
    }

    implicit val encodeStreamTransport: Encoder[StreamTransport] = new Encoder[StreamTransport] {
        final def apply(a: StreamTransport): Json = {
            a match {
                case s: StreamTransportHTTP => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.http.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportKafka => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.kafka.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportREST => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.rest.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportFile => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.file.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportODBC => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.odbc.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportTCP => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.tcp.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportUDP => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.udp.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportExec => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.exec.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportInline => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.inline.toString))
                ).deepMerge(s.asJson)
                case s: StreamTransportDiscard.type => Json.obj(
                    ("Type", Json.fromString(StreamTransportType.discard.toString))
                )
            }
        }
    }

    implicit val encodeStreamEnvelope: Encoder[StreamEnvelope] = new Encoder[StreamEnvelope] {
        final def apply(a: StreamEnvelope): Json = {
            a match {
                case s: StreamEnvelopeDelimited => Json.obj(
                    ("Type", Json.fromString(StreamEnvelopeType.delimited.toString))
                ).deepMerge(s.asJson)
                case s: StreamEnvelopeFixed => Json.obj(
                    ("Type", Json.fromString(StreamEnvelopeType.fixed.toString))
                ).deepMerge(s.asJson)
                case s: StreamEnvelopeOcfBlock => Json.obj(
                    ("Type", Json.fromString(StreamEnvelopeType.ocfBlock.toString))
                ).deepMerge(s.asJson)
            }
        }
    }

    implicit val encodeStream: Encoder[Stream] = new Encoder[Stream] {
        final def apply(a: Stream): Json = {
            var stream = Json.obj(
                ("Version", Json.fromString(a.version)),
                ("Description", if (a.description.isDefined) Json.fromString(a.description.get) else Json.Null),
                ("Transport", a.transport.asJson),
                ("Loop", Json.fromBoolean(a.loop)),
                ("Envelope", a.envelope match {
                    case Some(e) => e.asJson
                    case None => Json.Null
                }),
                ("Encoding", a.encoding match {
                    case Some(e) => Json.fromString(e.toString)
                    case None => Json.Null
                }),
                ("Batching", a.batching match {
                    case Left(b) => Json.fromString(b.toString)
                    case Right(b) => b.asJson
                }),
                ("LingerTime", Json.fromInt(a.lingerTime)),
                ("Schema", a.schema match {
                    case Some(s) => s match {
                        case Left(s) => Json.obj(("Schema", Json.fromString(s)))
                        case Right(s) => s.asJson
                    }
                    case None => Json.Null
                })
            )

            val skipTo: Option[Json] = a.skipTo match {
                case Some(s) => Some(Json.obj(("SkipTo", Json.fromInt(s))))
                case None => None
            }

            val skipToRecord: Option[Json] = a.skipToRecord match {
                case Some(Left(s)) => Some(Json.obj(("SkipToRecord", Json.fromInt(s))))
                case Some(Right(s)) => Some(Json.obj(("SkipToRecord", Json.fromString(s.toString))))
                case None => None
            }

            stream = if (skipTo.isDefined) stream.deepMerge(skipTo.get) else stream
            stream = if (skipToRecord.isDefined) stream.deepMerge(skipToRecord.get) else stream

            stream
        }
    }

    implicit val decodeStreamEnvelope: Decoder[StreamEnvelope] = new Decoder[StreamEnvelope] {
        final def apply(a: HCursor): Decoder.Result[StreamEnvelope] =
            for {
                _type <- a.downField("Type").as[String]
            } yield {
                StreamEnvelopeType.withName(_type) match {
                    case StreamEnvelopeType.delimited => a.as[StreamEnvelopeDelimited].right.get
                    case StreamEnvelopeType.fixed => a.as[StreamEnvelopeFixed].right.get
                    case StreamEnvelopeType.ocfBlock => a.as[StreamEnvelopeOcfBlock].right.get
                }
            }
    }

    implicit val decodeStream: Decoder[Stream] = new Decoder[Stream] {
        final def apply(c: HCursor): Decoder.Result[Stream] =
            for {
                description <- c.downField("Description").as[Option[String]]
                skipTo <- c.downField("SkipTo").as[Option[Int]]
                transport <- c.downField("Transport").as[StreamTransport]
            } yield {
                val transportField = c.downField("Transport")
                val skipToRecordField = c.downField("SkipToRecord")
                val envelopeField = c.downField("Envelope")
                val encodingField = c.downField("Encoding")
                val schemaField = c.downField("Schema")
                val batchingField = c.downField("Batching")
                val lingerTimeField = c.downField("LingerTime")
                val loop =
                    if (c.downField("Loop").succeeded && !c.downField("Loop").as[Boolean].isLeft)
                        c.downField("Loop").as[Boolean].right.get
                    else
                        false
                val version =
                    if (c.downField("Version").succeeded && !c.downField("Version").as[String].isLeft)
                        c.downField("Version").as[String].right.get
                    else
                        "1.2"
                
                val skipToRecord =
                    if (skipToRecordField.succeeded && !(skipToRecordField.as[Int].isLeft && skipToRecordField.as[String].isLeft))
                        skipToRecordField.as[Int] match {
                            case Right(s) => Some(Left(s))
                            case _ => Some(Right(KafkaSkipToRecord.withName(skipToRecordField.as[String].right.get)))
                        }
                    else
                        None
                val envelope =
                    if (envelopeField.succeeded)
                        envelopeField.as[String] match {
                            case Right(e) =>
                                StreamEnvelopeType.withName(e) match {
                                    case StreamEnvelopeType.delimited => Some(StreamEnvelopeDelimited("\n"))
                                    case _ => None
                                }
                            case Left(_) =>
                                if (envelopeField.downField("Type").succeeded && !envelopeField.as[StreamEnvelope].isLeft)
                                    Some(envelopeField.as[StreamEnvelope].right.get)
                                else
                                    None
                        }
                    else
                        None
                val encoding =
                    if (encodingField.succeeded && !encodingField.as[String].isLeft)
                        Some(StreamEncoding.withName(encodingField.as[String].right.get))
                    else
                        None
                val schema =
                    if (schemaField.succeeded && !(schemaField.as[String].isLeft && schemaField.as[StreamSchemaRef].isLeft))
                        schemaField.as[String] match {
                            case Right(s) => Some(Left(s))
                            case Left(_) =>
                                schemaField.as[StreamSchemaRef] match {
                                    case Right(schemaRef) => Some(Right(schemaRef))
                                    case Left(_) => None
                                }
                        }
                    else
                        throw FastScoreError("Malformed Stream: Schema field not defined")
                val batching =
                    if (batchingField.succeeded && !batchingField.as[String].isLeft)
                        batchingField.as[String] match {
                            case Right(b) => Left(StreamBatchingMode.withName(b))
                            case Left(_) => Right(batchingField.as[StreamBatching].right.get)
                        }
                    else
                        Left(StreamBatchingMode.normal)
                val lingerTime =
                    if (lingerTimeField.succeeded && !lingerTimeField.as[Int].isLeft)
                        lingerTimeField.as[Int].right.get
                    else
                        3000
                Stream(
                    version,
                    description,
                    transport,
                    loop,
                    skipTo,
                    skipToRecord,
                    envelope,
                    encoding,
                    schema,
                    batching,
                    lingerTime
                )
            }
    }
}