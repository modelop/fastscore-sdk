package com.opendatagroup.fastscore.assets.serializers

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.serializers.SensorSerializer.decodeSensorTap

import java.time.OffsetDateTime

import io.circe.{Decoder, HCursor}
import io.circe.java8.time._

/** Pnuemo Message Serializer/Deserializer
  *
  */
object PneumoMessageSerializer {
    implicit val decodeSensorTapInstance: Decoder[SensorTapInstance] = new Decoder[SensorTapInstance] {
        final def apply(a: HCursor): Decoder.Result[SensorTapInstance] =
            for {
                tap <- a.as[String]
            } yield {
                SensorTapInstance(
                    SensorTapPrefix.withName(tap.split('.')(0)),
                    tap.split('.')(1).toInt,
                    SensorTapSuffix.withName(tap.split('.').slice(2, tap.length).mkString("."))
                )
            }
    }

    implicit val decodeHealthMessage: Decoder[HealthMessage] = new Decoder[HealthMessage] {
        final def apply(a: HCursor): Decoder.Result[HealthMessage] =
            for {
                src <- a.downField("src").as[String]
                timestamp <- a.downField ("timestamp").as[OffsetDateTime]
                messageType <- a.downField ("type").as[String]
                instance <- a.downField("instance").as[String]
                health <- a.downField("health").as[String]
            } yield {
                HealthMessage(src, timestamp, PneumoMessageType.withName(messageType), instance, health)
            }
    }
    implicit val decodeEngineStateMessage: Decoder[EngineStateMessage] = new Decoder[EngineStateMessage] {
        final def apply(a: HCursor): Decoder.Result[EngineStateMessage] =
            for {
                src <- a.downField ("src").as[String]
                timestamp <- a.downField ("timestamp").as[OffsetDateTime]
                messageType <- a.downField ("type").as[String]
                state <- a.downField("state").as[String]
            } yield {
                EngineStateMessage(src, timestamp, PneumoMessageType.withName(messageType), EngineState.withName(state))
            }
    }
    implicit val decodeEngineConfigMessage: Decoder[EngineConfigMessage] = new Decoder[EngineConfigMessage] {
        final def apply(a: HCursor): Decoder.Result[EngineConfigMessage] =
            for {
                src <- a.downField ("src").as[String]
                timestamp <- a.downField ("timestamp").as[OffsetDateTime]
                messageType <- a.downField ("type").as[String]
                item <- a.downField("item").as[String]
            } yield {
                val ref = a.downField("ref").as[Int] match {
                    case Right(ref) => Left(ref)
                    case Left(_) => Right(a.downField("ref").as[String].right.get)
                }
                EngineConfigMessage(src, timestamp, PneumoMessageType.withName(messageType), EngineConfigItem.withName(item), ref)
            }
    }
    implicit val decodeLogMessage: Decoder[LogMessage] = new Decoder[LogMessage] {
        final def apply(a: HCursor): Decoder.Result[LogMessage] =
            for {
                src <- a.downField("src").as[String]
                timestamp <- a.downField ("timestamp").as[OffsetDateTime]
                messageType <- a.downField ("type").as[String]
                level <- a.downField("level").as[Int]
                text <- a.downField("text").as[String]
            } yield {
                LogMessage(src, timestamp, PneumoMessageType.withName(messageType), level, text)
            }
    }
    implicit val decodeModelConsoleMessage: Decoder[ModelConsoleMessage] = new Decoder[ModelConsoleMessage] {
        final def apply(a: HCursor): Decoder.Result[ModelConsoleMessage] =
            for {
                src <- a.downField ("src").as[String]
                timestamp <- a.downField ("timestamp").as[OffsetDateTime]
                messageType <- a.downField ("type").as[String]
                text <- a.downField("text").as[String]
            } yield {
                ModelConsoleMessage(src, timestamp, PneumoMessageType.withName(messageType), text)
            }
    }
    implicit val decodeInputBatch: Decoder[InputBatch] = new Decoder[InputBatch] {
        final def apply(a: HCursor): Decoder.Result[InputBatch] =
            for {
                slot <- a.downField("slot").as[Int]
                seqno <- a.downField("seqno").as[Int]
                data <- a.downField("data").as[List[String]]
                batchLen <- a.downField("batchLen").as[Int]
                encoding <- a.downField("encoding").as[String]
            } yield {
                InputBatch(
                    slot,
                    seqno,
                    data,
                    batchLen,
                    StreamEncoding.withName(encoding)
                )
            }
    }
    implicit val decodeModelErrorMessage: Decoder[ModelErrorMessage] = new Decoder[ModelErrorMessage] {
        final def apply(a: HCursor): Decoder.Result[ModelErrorMessage] =
            for {
                src <- a.downField ("src").as[String]
                timestamp <- a.downField ("timestamp").as[OffsetDateTime]
                messageType <- a.downField ("type").as[String]
                input <- a.downField("input").as[Option[InputBatch]]
                console <- a.downField("console").as[String]
            } yield {
                ModelErrorMessage(src, timestamp, PneumoMessageType.withName(messageType), input, console)
            }
    }
    implicit val decodeSensorReport: Decoder[SensorReportMessage] = new Decoder[SensorReportMessage] {
        final def apply(a: HCursor): Decoder.Result[SensorReportMessage] =
            for {
                src <- a.downField ("src").as[String]
                timestamp <- a.downField ("timestamp").as[OffsetDateTime]
                messageType <- a.downField ("type").as[String]
                id <- a.downField("id").as[Int]
                tap <- a.downField("tap").as[SensorTapInstance]
                data <- a.downField("data").as[Int]
                deltaTime <- a.downField("deltaTime").as[Option[Double]]
            } yield {
                SensorReportMessage(src,
                    timestamp,
                    PneumoMessageType.withName(messageType),
                    id,
                    tap,
                    data,
                    deltaTime
                )
            }
    }
}