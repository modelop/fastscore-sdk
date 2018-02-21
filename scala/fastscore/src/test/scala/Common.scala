import com.opendatagroup.fastscore.fleet.Proxy
import com.opendatagroup.fastscore.assets._
import scala.collection.immutable.{ Map, List }
import io.circe.parser._
import io.circe.syntax._

object Common {
    val PROXY_PREFIX = "https://localhost:8000"
    val ENGINE_NAME = "engine-1"
    val MODELMANAGE_NAME = "model-manage-1"

    private val modelSrc = """
          |# fastscore.schema.0: { "type": "int" }
          |# fastscore.schema.1: { "type": "int" }
          |
          |def action(datum):
          |  yield datum
        """.stripMargin

    private val modelSchema: Map[Int, String] = List((0, "int"), (1, "int")).toMap

    val model: Model = new Model("python", modelSrc, modelSchema)

    val rest = new Stream(
        transport = StreamTransportREST(StreamTransportRESTMode.simple),
        encoding = Some(StreamEncoding.json)
    )

    val sensor = Sensor(
        tap = SensorTap(SensorTapPrefix.sys, SensorTapSuffix.memory),
        description = Some("I'm a sensor"),
        activate = SensorActivate(SensorActivateType.random, Some(SensorActivateInterval(2.3)), None),
        filter = Some(SensorFilter(SensorFilterType.<=, Left(5))),
        aggregate = Some(SensorAggregate(SensorAggregateType.sum)),
        sink = SensorSinkPneumo
    )

    val stream = Stream(
        description = Some("write a sequence of unicode strings to a file separated by newlines"),
        transport = StreamTransportFile("data/output1.dat"),
        schema = Some(Right(StreamSchemaRef("input"))),
        batching = Left(StreamBatchingMode.normal)
    )

    val streamJSON = parse(stream.toString).right.get

    val streamBuilderJSON =
        """
          |{
          |  "SkipToRecord" : "earliest",
          |  "Version" : "1.2",
          |  "Description" : "I'm a stream",
          |  "Transport" : {
          |    "MaxWaitTime" : 524287,
          |    "Partition" : 4,
          |    "Type" : "Kafka",
          |    "BootstrapServers" : [
          |      "127.0.0.1:9092"
          |    ],
          |    "Topic" : "input"
          |  },
          |  "Loop" : true,
          |  "Envelope" : {
          |    "Type" : "ocf-block",
          |    "SkipHeader" : false
          |  },
          |  "Batching" : "explicit",
          |  "LingerTime" : 3000,
          |  "Schema" : {
          |    "$ref" : "input"
          |  }
          |}
        """.stripMargin
}