import org.scalatest._

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.builders._

import com.opendatagroup.fastscore.assets.serializers.SensorSerializer._
import io.circe.syntax._
import io.circe.parser._

import java.io.File

class SensorSpec extends FlatSpec with Matchers {
        val sensorJson = parse("""{
    "Tap" : "sys.memory",
    "Description" : "I'm a sensor",
    "Activate" : {
        "Interval" : 2.3,
        "Type" : "random",
        "MaxReads" : 1
    },
    "Filter" : {
        "Threshold" : 5,
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
    val sensor = Sensor(
        tap = SensorTap(SensorTapPrefix.sys, SensorTapSuffix.memory),
        description = Some("I'm a sensor"),
        activate = SensorActivate(SensorActivateType.random, Some(SensorActivateInterval(2.3)), None),
        filter = Some(SensorFilter(SensorFilterType.<=, Left(5))),
        aggregate = Some(SensorAggregate(SensorAggregateType.sum)),
        sink = SensorSinkPneumo
    )


    "Sensor" should "correctly serialize to json" in {
        sensor.asJson.spaces2 should be (sensorJson.toString)
    }

    it should "correctly deserialize from json" in {
        sensorJson.as[Sensor].right.get should be (sensor)
    }

    it should "correctly read/write to a file" in {
        new File("temp.json").delete()
        sensor.toFile("temp.json")
        sensor should be (Sensor.fromFile("temp.json"))
    }
}
