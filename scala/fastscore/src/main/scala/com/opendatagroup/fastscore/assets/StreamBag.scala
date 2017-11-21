package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet.ModelManage
import com.opendatagroup.fastscore.util._

class StreamBag(mm: ModelManage) extends Bag[StreamMetadata, Stream] {
    val modelmanage = mm
    def names(): List[String] = mm.v1.streamList(mm.toString) match {
        case Some(streams) => streams.map(_.toString)
        case None => List()
    }

    def put(name: String, stream: Stream): Unit = {
        modelmanage.v1.streamPut(modelmanage.toString, name, stream.toString)
    }

    def iterator = {
        mm.v1.streamList(mm.toString) match {
            case Some(streams) =>
                streams.iterator
                .map { name => StreamMetadata(name, mm) }
            case None => throw FastScoreError("Unexpected response from ModelManage")
        }
    }
}
