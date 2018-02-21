import org.scalatest._

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.builders._

import com.opendatagroup.fastscore.assets.serializers.StreamSerializer._
import io.circe.syntax._
import io.circe.parser._

import java.io.File
import Common._

class StreamSpec extends FlatSpec with Matchers {
    "Stream" should "correctly serialize/deserialize to/from json" in {
        parse(stream.toString).right.get.as[Stream].right.get should be (stream)
    }

    it should "correctly read/write to a file" in {
        val file = new File("stream.json")
        file.delete()
        stream.toFile("stream.json")
        stream should be (Stream.fromFile("stream.json"))
        file.delete()
    }

    "StreamBuilder" should "correctly build a stream" in {
        val targetStream = parse(streamBuilderJSON).right.get.as[Stream].right.get
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
