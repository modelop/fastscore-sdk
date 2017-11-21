package com.opendatagroup.fastscore.assets

import java.time.OffsetDateTime

object PneumoMessageType extends Enumeration {
    val health = Value("health")
    val log = Value("log")
    val modelConsole = Value("model-console")
    val engineState = Value("engine-state")
    val engineConfig = Value("engine-config")
    val sensorReport = Value("sensor-report")
    val modelError = Value("model-error")
}

trait SensorTapInstanceSerializer {
    val prefix: SensorTapPrefix.Value
    val slot: Int
    val suffix: SensorTapSuffix.Value

    override def toString(): String = s"${prefix.toString}.$slot.${suffix.toString}"

    def toTap(): SensorTap = SensorTap(prefix, suffix)
}

case class SensorTapInstance(
    prefix: SensorTapPrefix.Value,
    slot: Int,
    suffix: SensorTapSuffix.Value
) extends SensorTapInstanceSerializer

sealed trait PneumoMessage {
    val src: String
    val timestamp: OffsetDateTime
    val messageType: PneumoMessageType.Value
}

case class HealthMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    instance: String,
    health: String
) extends PneumoMessage

object EngineState extends Enumeration {
    val init = Value("init")
    val running = Value("running")
    val paused = Value("paused")
    val pigging = Value("pigging")
    val finishing = Value("finishing")
    val finished = Value("finished")
}

case class EngineStateMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    state: EngineState.Value
) extends PneumoMessage

object EngineConfigItem extends Enumeration {
    val model = Value("model")
    val stream = Value("stream")
    val jet = Value("jet")
}

case class EngineConfigMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    item: EngineConfigItem.Value,
    ref: Either[Int, String]
) extends PneumoMessage

case class LogMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    level: Int,
    text: String
) extends PneumoMessage

case class ModelConsoleMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    text: String
) extends PneumoMessage

case class InputBatch(
    slot: Int,
    seqno: Int,
    data: List[String],
    batchLen: Int,
    encoding: StreamEncoding.Value
)

case class ModelErrorMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    input: Option[InputBatch],
    console: String
) extends PneumoMessage

case class SensorReportMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    id: Int,
    tap: SensorTapInstance,
    data: Int,
    deltaTime: Option[Double]
) extends PneumoMessage