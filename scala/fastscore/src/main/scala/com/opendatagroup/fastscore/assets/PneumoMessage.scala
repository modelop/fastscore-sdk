package com.opendatagroup.fastscore.assets

import java.time.OffsetDateTime

/** Pneumo message types
  *
  */
object PneumoMessageType extends Enumeration {
    val health = Value("health")
    val log = Value("log")
    val modelConsole = Value("model-console")
    val engineState = Value("engine-state")
    val engineConfig = Value("engine-config")
    val sensorReport = Value("sensor-report")
    val modelError = Value("model-error")
}

/** SensorTapInstance serializer helper trait
  *
  */
trait SensorTapInstanceSerializer {
    val prefix: SensorTapPrefix.Value
    val slot: Int
    val suffix: SensorTapSuffix.Value

    override def toString(): String = s"${prefix.toString}.$slot.${suffix.toString}"

    /** Converts SensorTapInstance to SensorTap
      *
      * @return SensorTap
      */
    def toTap(): SensorTap = SensorTap(prefix, suffix)
}

/** SensorTapInstance
  *
  * Sensor Tap + Slot it's attached to
  *
  * @param prefix Sensor Tap prefix
  * @param slot Sensor Slot
  * @param suffix Sensor Tap suffix
  */
case class SensorTapInstance(
    prefix: SensorTapPrefix.Value,
    slot: Int,
    suffix: SensorTapSuffix.Value
) extends SensorTapInstanceSerializer

/** Pneumo Message parent trait
  *
  */
sealed trait PneumoMessage {
    val src: String
    val timestamp: OffsetDateTime
    val messageType: PneumoMessageType.Value
}

/** Pneumo Health Message
  *
  * @param src
  * @param timestamp
  * @param messageType
  * @param instance
  * @param health
  */
case class HealthMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    instance: String,
    health: String
) extends PneumoMessage

/** EngineState parameter values
  *
  */
object EngineState extends Enumeration {
    val init = Value("init")
    val running = Value("running")
    val paused = Value("paused")
    val pigging = Value("pigging")
    val finishing = Value("finishing")
    val finished = Value("finished")
}

/** Pneumo Engine State Message
  *
  * @param src
  * @param timestamp
  * @param messageType
  * @param state
  */
case class EngineStateMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    state: EngineState.Value
) extends PneumoMessage

/** Pneumo EngineConfigItem values
  *
  */
object EngineConfigItem extends Enumeration {
    val model = Value("model")
    val stream = Value("stream")
    val jet = Value("jet")
}

/** Pneumo Engine Config Message
  *
  * @param src
  * @param timestamp
  * @param messageType
  * @param item
  * @param ref
  */
case class EngineConfigMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    item: EngineConfigItem.Value,
    ref: Either[Int, String]
) extends PneumoMessage

/** Pneumo Engine Log Message
  *
  * @param src
  * @param timestamp
  * @param messageType
  * @param level
  * @param text
  */
case class LogMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    level: Int,
    text: String
) extends PneumoMessage

/** Pneumo Model Console Message
  *
  * @param src
  * @param timestamp
  * @param messageType
  * @param text
  */
case class ModelConsoleMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    text: String
) extends PneumoMessage

/** Pneumo Input Batch Message
  *
  * @param slot
  * @param seqno
  * @param data
  * @param batchLen
  * @param encoding
  */
case class InputBatch(
    slot: Int,
    seqno: Int,
    data: List[String],
    batchLen: Int,
    encoding: StreamEncoding.Value
)

/** Pneumo Model Error Message
  *
  * @param src
  * @param timestamp
  * @param messageType
  * @param input
  * @param console
  */
case class ModelErrorMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    input: Option[InputBatch],
    console: String
) extends PneumoMessage

/** Pneumo Sensor Report Message
  *
  * @param src
  * @param timestamp
  * @param messageType
  * @param id
  * @param tap
  * @param data
  * @param deltaTime
  */
case class SensorReportMessage(
    src: String,
    timestamp: OffsetDateTime,
    messageType: PneumoMessageType.Value,
    id: Int,
    tap: SensorTapInstance,
    data: Int,
    deltaTime: Option[Double]
) extends PneumoMessage