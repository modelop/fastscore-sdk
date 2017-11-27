package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.swagger.api1.{ EngineApi => EngineApi1 }
import com.opendatagroup.fastscore.swagger.api2.{ EngineApi => EngineApi2 }
import com.opendatagroup.fastscore.util.FastScoreError
import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.Constants._

class Engine(name: String)(
    implicit val proxy: Proxy
) extends Instance {

    override def toString = name

    val v1 = new EngineApi1(proxy.basePath) with SwaggerBase1
    val v2 = new EngineApi2(proxy.basePath) with SwaggerBase2

    def state(): String = {
        v2.engineStateGet(this.toString) match {
            case Some(response) => response.state match {
                case Some(state) => state
                case None => throw FastScoreError("Empty state")
            }
            case None => throw FastScoreError("Unexpected response from engine")
        }
    }

    def reset(): Unit = {
        v2.engineReset(this.toString)
    }

    def model(): Option[Model] = {
        v2.activeModelGet(this.toString) match {
            case Some(modelInfo) => Some(Model(modelInfo.mtype.get, modelInfo.source.get))
            case None => None
        }
    }

    def unloadModel(): Unit = {
        v2.activeModelDelete(this.toString)
    }

    def loadModel(model: Model): Unit = {
        v1.modelLoad(this.toString, model.toString, _contentType = MODEL_CONTENT_TYPES.get(model.format))
    }

    def attachStream(slot: Int, stream: Stream): Unit = {
        println(s"Attaching stream to slot $slot")
        v2.activeStreamAttach(this.toString, stream.toString, slot, dryRun = Some(false), contentDisposition = Some("inline"))
    }
}