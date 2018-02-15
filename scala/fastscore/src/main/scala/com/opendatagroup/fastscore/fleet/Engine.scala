package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.swagger.api1.{ EngineApi => EngineApi1 }
import com.opendatagroup.fastscore.swagger.api2.{ EngineApi => EngineApi2 }
import com.opendatagroup.fastscore.util.FastScoreError
import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.Constants._

/** Engine classes
  *
  * ==Overview==
  * The main engine class is [[com.opendatagroup.fastscore.fleet.Engine]]
  * It defines a reference to a running engine instance
  * An Engine object can be created the following ways:
  * 1. From a Connect instance
  * {{{
  *     scala> implicit val proxy = new Proxy("https://localhost:8000")
  *     scala> val connect = new Connect()
  *     scala> val engine = connect.get("engine-1") match { case Some(engine): Option[Engine] => engine }
  * }}}
  * 2. Directly
  * {{{
  *     scala> implicit val proxy = new Proxy("https://localhost:8000")
  *     scala> val engine = new Engine("engine-1")
  * }}}
  */
class Engine(name: String)(
    implicit val proxy: Proxy
) extends Instance {

    override def toString = name

    val v1 = new EngineApi1(proxy.basePath) with SwaggerBase1
    val v2 = new EngineApi2(proxy.basePath) with SwaggerBase2

    /** Retrieve the state of the engine
      *
      * @return INIT, RUNNING, ERROR
      */
    def state(): String = {
        v2.engineStateGet(this.toString) match {
            case Some(response) => response.state match {
                case Some(state) => state
                case None => throw FastScoreError("Empty state")
            }
            case None => throw FastScoreError("Unexpected response from engine")
        }
    }

    /** Reset the engine to INIT state
      *
      */
    def reset(): Unit = {
        v2.engineReset(this.toString)
    }

    /** Retrieve the active model
      *
      * @return
      */
    def model(): Option[Model] = {
        v2.activeModelGet(this.toString) match {
            case Some(modelInfo) => Some(Model(modelInfo.mtype.get, modelInfo.source.get, ModelParseOps.extractSchemas(modelInfo.mtype.get, modelInfo.source.get)))
            case None => None
        }
    }

    /** Unload active model
      *
      */
    def unloadModel(): Unit = {
        v2.activeModelDelete(this.toString)
    }

    /** Load a model
      *
      * @param model
      */
    def loadModel(model: Model): Unit = {
        v1.modelLoad(this.toString, model.toString, _contentType = MODEL_CONTENT_TYPES.get(model.format))
    }

    /** Attach a stream
      *
      * @param slot Slot to attach to
      * @param stream Stream object to attach
      */
    def attachStream(slot: Int, stream: Stream): Unit = {
        println(s"Attaching stream to slot $slot")
        v2.activeStreamAttach(this.toString, stream.toString, slot, dryRun = Some(false), contentDisposition = Some("inline"))
    }
}