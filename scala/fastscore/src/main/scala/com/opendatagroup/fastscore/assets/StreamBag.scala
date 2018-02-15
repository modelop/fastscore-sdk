package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet.ModelManage
import com.opendatagroup.fastscore.util._

/** A live collection of streams in ModelManage
  *
  * @param mm ModelManage instance
  */
class StreamBag(mm: ModelManage) extends Bag[StreamMetadata, Stream] {
    val modelmanage = mm

    /** Returns a list of stream names in ModelManage
      *
      * @return list of stream names
      */
    def names(): List[String] = mm.v1.streamList(mm.toString) match {
        case Some(streams) => streams.map(_.toString)
        case None => List()
    }

    /** Add a stream to ModelManage
      *
      * @param name stream name in ModelManage
      * @param stream stream object
      */
    def put(name: String, stream: Stream): Unit = {
        modelmanage.v1.streamPut(modelmanage.toString, name, stream.toString)
    }

    /** List of streams
      *
      * @return list of streams
      */
    def iterator = {
        mm.v1.streamList(mm.toString) match {
            case Some(streams) =>
                streams.iterator
                .map { name => StreamMetadata(name, mm) }
            case None => throw FastScoreError("Unexpected response from ModelManage")
        }
    }
}
