import org.scalatest._

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.builders._

import com.opendatagroup.fastscore.assets.serializers.SensorSerializer._
import io.circe.syntax._
import io.circe.parser._

import Common._

import java.io.File

class SensorSpec extends FlatSpec with Matchers {
    "Sensor" should "correctly serialize/deserialize to/from json" in {
        parse(sensor.toString).right.get.as[Sensor].right.get should be (sensor)
    }

    it should "correctly read/write to a file" in {
        val file = new File("sensor.json")
        file.delete()
        sensor.toFile("sensor.json")
        sensor should be (Sensor.fromFile("sensor.json"))
        file.delete()
    }
}
