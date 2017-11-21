package com.opendatagroup.fastscore

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.assets._
import io.circe.syntax._
import com.opendatagroup.fastscore.assets.serializers.StreamSerializer._
import com.opendatagroup.fastscore.assets.serializers.SensorSerializer._
import com.opendatagroup.fastscore.assets.builders._
import io.circe.generic.auto._
import io.circe.parser._
import com.opendatagroup.fastscore.util.SSLVerify._

object Test extends App {

    disableSSLVerify()

    implicit val proxy = new Proxy("https://127.0.0.1:8000")

    val connect = new Connect

    val engine = connect.lookup("engine")(0).asInstanceOf[Engine]

    val model = Model.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/cluster.pfa")

    val in = Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-in.json").toBuilder.withLoop(false).endStream

    engine.loadModel(model)

    engine.attachStream(0, in)

    val modelmanage = connect.lookup("model-manage")(0).asInstanceOf[ModelManage]

    //val pneumo = new Pneumo

    Sensor.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/sensors/sensor.json")
        .toBuilder
        .withNewTap
            .withSuffix(SensorTapSuffix.memory)
            .withPrefix(SensorTapPrefix.sys)
        .endTap
        .endSensor
            .toFile("/Users/george/Documents/Work/fastscore-integration-tests/sensors/sensor.json")

    Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-in.json")
        .toBuilder
        .withEncoding(StreamEncoding.avroBinary)
        .endStream
        .toFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-in.json")

//    val jobDone = pneumo.stream.filter {
//        case msg: EngineStateMessage => msg.state == EngineState.finished
//        case _ => false
//    }.take(1)

    //pneumo.close

    Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-in.json").toBuilder
        .withLoop(true)
        .endStream
        .toFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-in.json")


    val mm = new ModelManage("model-manage-1")

    val stream = new StreamBuilder()
        .withDescription("I'm a stream")
            .withNewKafkaTransport
            .withBootStrapServer("127.0.0.1:9092")
            .withTopic("input")
            .withPartition(4)
        .endTransport
        .withLoop(true)
        .withSkipToKafkaRecord(KafkaSkipToRecord.earliest)
        .withNewOcfBlockEnvelope
            .withSkipHeader(false)
        .endEnvelope
        .withNewSchemaRef
            .withRef("input")
        .endSchema
        .withBatching(StreamBatchingMode.explicit)
        .endStream

    println(stream.toString)

    val s = new SensorBuilder()
        .withDescription("I'm a sensor")
        .withNewTap
            .withPrefix(SensorTapPrefix.sys)
            .withSuffix(SensorTapSuffix.memory)
        .endTap
        .withNewActivate
            .withType(SensorActivateType.permanent)
            .withInterval(SensorActivateInterval(1.0))
            .withMaxReads(5)
            .withDuration(60)
        .endActivate
        .withNewFilter
            .withType(SensorFilterType.<=)
            .withThreshold(11)
            .withMaxValue(5.5)
        .endFilter
        .withNewAggregate
          .withType(SensorAggregateType.accumulate)
          .withSampleSize(11)
        .endAggregate
        .withNewSink
          .withType(SensorSinkType.kafka)
          .withTopic("sensor")
          .withPartition(10)
        .endSink
        .endSensor


        val sensorJson = parse("""{
    "Tap" : "sys.memory",
    "Description" : "I'm a sensor",
    "Activate" : {
        "Interval" : 2.3,
        "Type" : "random",
        "MaxReads" : 1
    },
    "Filter" : {
        "Threshold" : 5.0,
        "Type" : "<="
    },
    "Aggregate" : {
        "Type" : "sum"
    },
    "Sink" : {
        "Type" : "Pneumo"
    },
    "Report" : null
}""").right.get

    println(sensorJson.as[Sensor].right.get.toString)
}