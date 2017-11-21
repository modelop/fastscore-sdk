package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.swagger.api1.{ EngineApi => EngineApi1 }
import com.opendatagroup.fastscore.swagger.api2.{ EngineApi => EngineApi2 }
import com.opendatagroup.fastscore.util.FastScoreError
import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.Constants._

import com.opendatagroup.fastscore.swagger.models1._
import com.opendatagroup.fastscore.swagger.models2.InlineResponse2001

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

    case class ModelInfo(

    )

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
        v2.activeStreamAttach(this.toString, stream.toString, slot)
    }



//    def attachments(): List[AttachmentMeta]
//
//    def model(): Option[ModelInfo] = {
//        v2.activeModelGet(this.toString).get.
//    }
}


// implicit val proxy = new Proxy("https://127.0.0.1:8000")

// val connect = new Connect

//mm.models.put("model", Model.fromFile("model.py"))
//
//val model1 =
//    new EngineBuilder()
//        .withModel(mm.models.get("model"))
//        .withInputSchema(Schema.fromStream(Stream.fromFile("file-in.json")))
//        .withOutputSchema(Schema.fromStream(Stream.fromFile("file-out.json")))
//        .withInputStream(Stream.fromFile("file-in.json"))
//        .withOutputStream(Stream.fromFile("file-out.json"))
//        .withConnect(connect)

// Stream.fromFile("file-in.json")
//     |> new EngineBuilder().withModel(Model.fromFile("model.py"))
//         |> Stream.fromFile("file-out.json")
//
//
// stream1 |> model1 |> stream2 |> model2 |> stream3 |> model4.slot1 |> stream5
//                      stream2 |> model3               model4.slot3 |> stream6
//                                                      model4.slot5 |> stream7