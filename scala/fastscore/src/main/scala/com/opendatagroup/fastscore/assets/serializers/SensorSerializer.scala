package com.opendatagroup.fastscore.assets.serializers

import com.opendatagroup.fastscore.assets._

import io.circe._
import io.circe.syntax._
import io.circe.generic.semiauto.deriveDecoder
import io.circe.Decoder



object SensorSerializer {
  implicit val encodeSensorActivate: Encoder[SensorActivate] = new Encoder[SensorActivate] {
    final def apply(a: SensorActivate): Json = {
      var activate = Json.obj(
        ("Type", Json.fromString(a._type.toString)),
        ("MaxReads", Json.fromInt(a.maxReads.getOrElse(1)))
      )

      val intensityOrInterval: Option[Json] = {
        a.intensityOrInterval match {
          case Some(SensorActivateIntensity(value: Double)) =>
            Some(Json.obj(("Intensity", Json.fromDouble(value).get)))
          case Some(SensorActivateInterval(value: Double)) =>
            Some(Json.obj(("Interval", Json.fromDouble(value).get)))
          case None => None
        }
      }

      val duration: Option[Json] = a.duration match {
        case Some(d) => Some(Json.obj(("Duration", Json.fromDouble(d).get)))
        case None => None
      }

      activate = if (duration.isDefined) activate.deepMerge(duration.get) else activate

      activate = if (intensityOrInterval.isDefined) activate.deepMerge(intensityOrInterval.get) else activate

      activate
    }
  }

  implicit val encodeSensorFilter: Encoder[SensorFilter] = new Encoder[SensorFilter] {
    final def apply(a: SensorFilter): Json = {
      var filter = Json.obj(
        ("Type", Json.fromString(a._type.toString))
      )

      val threshold: Json = a.threshold match {
        case Left(t) => Json.obj(("Threshold", Json.fromInt(t)))
        case Right(t) => Json.obj(("Threshold", Json.fromDouble(t).get))
      }

      filter = filter.deepMerge(threshold)

      val minValue: Option[Json] = a.minValue match {
        case Some(Left(v)) => Some(Json.obj(("MinValue", Json.fromInt(v))))
        case Some(Right(v)) => Some(Json.obj(("MinValue", Json.fromDouble(v).get)))
        case None => None
      }

      filter = if (minValue.isDefined) filter.deepMerge(minValue.get) else filter

      val maxValue: Option[Json] = a.maxValue match {
        case Some(Left(v)) => Some(Json.obj(("MaxValue", Json.fromInt(v))))
        case Some(Right(v)) => Some(Json.obj(("MaxValue", Json.fromDouble(v).get)))
        case None => None
      }

      filter = if (maxValue.isDefined) filter.deepMerge(maxValue.get) else filter

      filter
    }
  }

  implicit val encodeSensorAggregate: Encoder[SensorAggregate] = new Encoder[SensorAggregate] {
    final def apply(a: SensorAggregate): Json = {
      var aggregate = Json.obj(
        ("Type", Json.fromString(a._type.toString))
      )

      val sampleSize: Option[Json] = a.sampleSize match {
        case Some(s) => Some(Json.obj(("SampleSize", Json.fromInt(s))))
        case None => None
      }

      aggregate = if (sampleSize.isDefined) aggregate.deepMerge(sampleSize.get) else aggregate

      aggregate
    }
  }

  implicit val encodeSensorSink: Encoder[SensorSink] = new Encoder[SensorSink] {
    final def apply(a: SensorSink): Json = a match {
      case SensorSinkPneumo =>
        Json.obj(("Type", Json.fromString("Pneumo")))
      case SensorSinkKafka(topic, Some(partition)) =>
        Json.obj(
          ("Type", Json.fromString("Kafka")),
          ("Topic", Json.fromString(topic)),
          ("Partition", Json.fromInt(partition))
        )
      case SensorSinkKafka(topic, None) =>
        Json.obj(
          ("Type", Json.fromString("Kafka")),
          ("Topic", Json.fromString(topic))
        )
    }
  }

  implicit val encodeSensorReport: Encoder[SensorReport] = new Encoder[SensorReport] {
    final def apply(a: SensorReport): Json = Json.obj(
      ("Interval", Json.fromDouble(a.interval).get)
    )
  }

  implicit val decodeSensorTap: Decoder[SensorTap] = new Decoder[SensorTap] {
    final def apply(a: HCursor): Decoder.Result[SensorTap] =
      for {
        tap <- a.as[String]
      } yield {
        SensorTap(SensorTapPrefix.withName(tap.split('.')(0)), SensorTapSuffix.withName(tap.split('.').tail.mkString(".")))
      }
  }

  // These derived decoders don't work right -- rewrite manually
  implicit val decodeSensorActivateIntensity: Decoder[SensorActivateIntensity] = new Decoder[SensorActivateIntensity] {
    final def apply(a: HCursor): Decoder.Result[SensorActivateIntensity] =
      for {
        value <- a.as[Double]
      } yield {
        SensorActivateIntensity(value)
      }
  }
  implicit val decodeSensorActivateInterval: Decoder[SensorActivateInterval] = new Decoder[SensorActivateInterval] {
    final def apply(a: HCursor): Decoder.Result[SensorActivateInterval] =
      for {
        value <- a.as[Double]
      } yield {
        SensorActivateInterval(value)
      }
  }

  implicit val decodeSensorActivate: Decoder[SensorActivate] = new Decoder[SensorActivate] {
    final def apply(a: HCursor): Decoder.Result[SensorActivate] = {
      for {
        _type <- a.downField("Type").as[String]
      } yield {
        val intensityOrInterval: Option[SensorActivateIntensityOrInterval] =
          if (a.downField("Intensity").succeeded)
            a.downField("Intensity").as[SensorActivateIntensity].right.toOption
          else if (a.downField("Interval").succeeded)
            a.downField("Interval").as[SensorActivateInterval].right.toOption
          else None
        val duration: Option[Double] =
          if (a.downField("Duration").succeeded)
            a.downField("Duration").as[Double].right.toOption
          else
            None
        val maxReads: Option[Int] =
          if (a.downField("MaxReads").succeeded)
            a.downField("MaxReads").as[Int].right.toOption
          else
            Some(1)
        SensorActivate(
          SensorActivateType.withName(_type),
          intensityOrInterval,
          duration,
          maxReads
        )
      }
    }
  }

  implicit val decodeSensorFilter: Decoder[SensorFilter] = new Decoder[SensorFilter] {
    final def apply(a: HCursor): Decoder.Result[SensorFilter] =
      for {
        _type <- a.downField("Type").as[String]
      } yield {
        val threshold = {
            val thresholdF = a.downField("Threshold").as[Double].right.get
            if (thresholdF / thresholdF.toInt == 1.0)
              Left(thresholdF.toInt)
            else
              Right(thresholdF)
        }

        val minValue = {
          if (a.downField("MinValue").succeeded) {
            val minValueF = a.downField("MinValue").as[Double].right.get
            if (minValueF / minValueF.toInt == 1.0)
              Some(Left(minValueF.toInt))
            else
              Some(Right(minValueF))
          } else None
        }

        val maxValue = {
          if (a.downField("MaxValue").succeeded) {
            val maxValueF = a.downField("MaxValue").as[Double].right.get
            if (maxValueF / maxValueF.toInt == 1.0)
              Some(Left(maxValueF.toInt))
            else
              Some(Right(maxValueF))
          } else None
        }


        SensorFilter(
          SensorFilterType.withName(_type),
          threshold,
          minValue,
          maxValue
        )
      }
  }

  implicit val decodeSensorAggregate: Decoder[SensorAggregate] = new Decoder[SensorAggregate] {
    final def apply(a: HCursor): Decoder.Result[SensorAggregate] =
      for {
        _type <- a.downField("Type").as[String]
      } yield {
        val sampleSize =
          if (a.downField("SampleSize").succeeded)
            a.downField("SampleSize").as[Int].right.toOption
          else
            None
        
        SensorAggregate(
          SensorAggregateType.withName(_type),
          sampleSize
        )
      }
  }

  implicit val decodeSensorSink: Decoder[SensorSink] = new Decoder[SensorSink] {
    final def apply(a: HCursor): Decoder.Result[SensorSink] =
      for {
        _type <- a.downField("Type").as[String]
      } yield {
        _type match {
          case "Pneumo" => SensorSinkPneumo
          case "Kafka" =>
            val topic = a.downField("Topic").as[String].right.get
            val partition =
              if (a.downField("Partition").succeeded)
                a.downField("Partition").as[Int].right.toOption
              else
                Some(0)
            SensorSinkKafka(topic, partition)
        }
      }
  }

  implicit val decodeSensorReport: Decoder[SensorReport] = new Decoder[SensorReport] {
    final def apply(a: HCursor): Decoder.Result[SensorReport] =
      for {
        interval <- a.downField("Interval").as[Double]
      } yield {
        SensorReport(interval)
      }
  }

  implicit val decodeSensor: Decoder[Sensor] = new Decoder[Sensor] {
    final def apply(c: HCursor): Decoder.Result[Sensor] =
      for {
        tap <- c.downField("Tap").as[SensorTap]
        activate <- c.downField("Activate").as[SensorActivate]
        filter <- c.downField("Filter").as[Option[SensorFilter]]
        aggregate <- c.downField("Aggregate").as[Option[SensorAggregate]]
        report <- c.downField("Report").as[Option[SensorReport]]
      } yield {
        val sink =
          if (c.downField("Sink").succeeded)
            c.downField("Sink").as[SensorSink].right.get
          else
            SensorSinkPneumo
        val description = c.downField("Description").as[String].right.toOption
        Sensor(tap, description, activate, filter, aggregate, sink, report)
      }
  }


  implicit val encodeSensor: Encoder[Sensor] = new Encoder[Sensor] {
    final def apply(a: Sensor): Json = Json.obj(
      ("Tap", Json.fromString(a.tap.toString)),
      ("Description", if (a.description.isDefined) Json.fromString(a.description.get) else Json.Null),
      ("Activate", a.activate.asJson),
      ("Filter", if (a.filter.isDefined) a.filter.asJson else Json.Null),
      ("Aggregate", if (a.aggregate.isDefined) a.aggregate.asJson else Json.Null),
      ("Sink", a.sink.asJson),
      ("Report", if (a.report.isDefined) a.report.asJson else Json.Null)
    )
  }
}