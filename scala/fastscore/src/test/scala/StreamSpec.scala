import org.scalatest._

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.builders._

import com.opendatagroup.fastscore.assets.serializers.StreamSerializer._
import io.circe.syntax._
import io.circe.parser._

import java.io.File

class StreamSpec extends FlatSpec with Matchers {
    val stream = Stream(
        description = Some("write a sequence of unicode strings to a file separated by newlines"),
        transport = StreamTransportFile("data/output1.dat"),
        schema = Some(Right(StreamSchemaRef("input"))),
        batching = Left(StreamBatchingMode.normal)
    )

    val streamJson = parse(
        """
          |{
          |  "Version" : "1.2",
          |  "Description" : "write a sequence of unicode strings to a file separated by newlines",
          |  "Transport" : {
          |    "Type" : "file",
          |    "Path" : "data/output1.dat"
          |  },
          |  "Loop" : false,
          |  "Envelope" : {
          |    "Type" : "delimited",
          |    "Separator" : "\n"
          |  },
          |  "Batching" : "normal",
          |  "LingerTime" : 3000,
          |  "Schema" : {
          |    "$ref" : "input"
          |  }
          |}
        """.stripMargin).right.get

    val streamBuilderJson = parse(
      """
        |{
        |    "SkipToRecord" : "earliest",
        |    "Version" : "1.2",
        |    "Description" : "I'm a stream",
        |    "Transport" : {
        |        "MaxWaitTime" : 524287,
        |        "Partition" : 4,
        |        "Type" : "Kafka",
        |        "BootstrapServers" : [
        |            "127.0.0.1:9092"
        |        ],
        |        "Topic" : "input"
        |    },
        |    "Loop" : true,
        |    "Envelope" : {
        |        "Type" : "ocf-block",
        |        "SkipHeader" : false
        |    },
        |    "Batching" : "explicit",
        |    "LingerTime" : 3000,
        |    "Schema" : {
        |        "$ref" : "input"
        |    }
        |}
      """.stripMargin).right.get

    "Stream" should "correctly deserialize from json" in {
        streamJson.as[Stream].right.get should be (stream)
    }

    it should "correctly serialize to json" in {
        stream.asJson should be (streamJson)
    }

    it should "correctly read/write to a file" in {
        new File("temp.json").delete()
        stream.toFile("temp.json")
        stream should be (Stream.fromFile("temp.json"))
    }

    "StreamBuilder" should "correctly build a stream" in {
        val targetStream = streamBuilderJson.as[Stream].right.get
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
        stream should be (targetStream)
    }
}
