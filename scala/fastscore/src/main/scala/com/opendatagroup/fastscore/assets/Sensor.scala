package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._
import com.opendatagroup.fastscore.assets.builders._

import com.opendatagroup.fastscore.assets.serializers.SensorSerializer._
import io.circe.parser._
import io.circe.syntax._

import scala.io.Source
import java.io.{ File, PrintWriter }

// Tap
object SensorTapPrefix extends Enumeration {
    val sys = Value("sys")
    val manifold = Value("manifold")
    val jet = Value("jet")
}

object SensorTapSuffix extends Enumeration {
    val records = Value("records")
    val recordsCount = Value("records.count")
    val recordsSize = Value("records.size")
    val recordsRejectedBySchema = Value("records.rejected.by.schema")
    val recordsRejectedByEncoding = Value("records.rejected.by.encoding")
    val rawSize = Value("raw.size")
    val cpuUtilization = Value("cpu.utilization")
    val memory = Value("memory")
    val profile = Value("profile")
    val debug = Value("debug")
}

trait SensorTapSerializer {
    val prefix: SensorTapPrefix.Value
    val suffix: SensorTapSuffix.Value

    override def toString(): String = {
        s"${prefix.toString}.${suffix.toString}"
    }
}

case class SensorTap(
    prefix: SensorTapPrefix.Value,
    suffix: SensorTapSuffix.Value,
) extends SensorTapSerializer

// Activate
object SensorActivateType extends Enumeration {
    val permanent = Value("permanent")
    val regular = Value("regular")
    val random = Value("random")
}

sealed trait SensorActivateIntensityOrInterval
case class SensorActivateIntensity(value: Double) extends SensorActivateIntensityOrInterval
case class SensorActivateInterval(value: Double) extends SensorActivateIntensityOrInterval

case class SensorActivate(
    _type: SensorActivateType.Value,
    intensityOrInterval: Option[SensorActivateIntensityOrInterval] = None,
    duration: Option[Double] = None,
    maxReads: Option[Int] = Some(1)
)

// Filter
object SensorFilterType extends Enumeration {
    val > = Value(">")
    val >= = Value(">=")
    val < = Value("<")
    val <= = Value("<=")
    val withinRange = Value("within-range")
    val outsideRange = Value("outside-range")
}

case class SensorFilter(
    _type: SensorFilterType.Value,
    threshold: Either[Int, Double],
    minValue: Option[Either[Int, Double]] = None,
    maxValue: Option[Either[Int, Double]] = None
)

object SensorAggregateType extends Enumeration {
    val accumulate = Value("accumulate")
    val sum = Value("sum")
    val count = Value("count")
}

case class SensorAggregate(
    _type: SensorAggregateType.Value = SensorAggregateType.accumulate,
    sampleSize: Option[Int] = None
)

object SensorSinkType extends Enumeration {
    val pneumo = Value("Pneumo")
    val kafka = Value("Kafka")
}

// Sink
sealed trait SensorSink

case object SensorSinkPneumo extends SensorSink

case class SensorSinkKafka(
    topic: String,
    partition: Option[Int] = Some(0)
) extends SensorSink


// Report
case class SensorReport(
    interval: Double = 0.0
)

object Sensor {
    def fromFile(path: String): Sensor = {
        val source = Source.fromFile(path).getLines.mkString
        parse(source) match {
            case Right(j) =>
                j.as[Sensor] match {
                    case Right(s) => s
                    case Left(_) => throw FastScoreError("Invalid sensor spec")
                }
            case Left(_) => throw FastScoreError("Malformed sensor JSON")
        }
    }
}

case class Sensor(
    tap: SensorTap,
    description: Option[String] = None,
    activate: SensorActivate,
    filter: Option[SensorFilter] = None,
    aggregate: Option[SensorAggregate] = None,
    sink: SensorSink = SensorSinkPneumo,
    report: Option[SensorReport] = None
) extends SensorJSONSerializer

trait SensorJSONSerializer {
    val tap: SensorTap
    val description: Option[String]
    val activate: SensorActivate
    val filter: Option[SensorFilter]
    val aggregate: Option[SensorAggregate]
    val sink: SensorSink
    val report: Option[SensorReport]

    override def toString(): String = {
        Sensor(tap, description, activate, filter, aggregate, sink, report).asJson.spaces4
    }

    def toFile(path: String): Unit = {
        val writer = new PrintWriter(new File(path))
        writer.write(Sensor(tap, description, activate, filter, aggregate, sink, report).toString)
        writer.close
    }

    def toBuilder(): SensorBuilder = {
        new SensorBuilder(
            Some(new SensorTapBuilder(Some(tap.prefix), Some(tap.suffix))(_)),
            Some(new SensorActivateBuilder(Some(activate._type), activate.intensityOrInterval, activate.duration, activate.maxReads)(_)),
            sink match {
                case s: SensorSinkPneumo.type => Some(new SensorSinkBuilder(SensorSinkType.pneumo)(_))
                case s: SensorSinkKafka => Some(new SensorSinkBuilder(SensorSinkType.kafka, Some(s.topic), s.partition)(_))
            },
            description,
            filter match {
                case Some(filter) => Some(new SensorFilterBuilder(Some(filter._type), Some(filter.threshold), filter.maxValue, filter.minValue)(_))
                case None => None
            },
            aggregate match {
                case Some(aggregate) => Some(new SensorAggregateBuilder(aggregate._type, aggregate.sampleSize)(_))
                case None => None
            },
            report match {
                case Some(report) => Some(new SensorReportBuilder(report.interval)(_))
                case None => None
            }
        )
    }
}

sealed trait SensorMetaOps {
    val name: String
    val modelmanage: ModelManage

    def get(): Sensor = {
        modelmanage.v1.sensorGet(modelmanage.toString, name) match {
            case Some(source) =>
                parse(source.toString) match {
                    case Right(json) => json.as[Sensor] match {
                        case Right(sensor) => sensor
                        case Left(_) => throw FastScoreError("Failed to parse sensor")
                    }
                    case Left(_) => throw FastScoreError("Malformed sensor JSON")   
                }
            case None => throw FastScoreError("Sensor not found")
        }
    }

    def delete(): Unit = {
        modelmanage.v1.sensorDelete(modelmanage.toString, name)
    }
}

case class SensorMetadata(
    name: String,
    modelmanage: ModelManage
) extends SensorMetaOps with Asset[Sensor]