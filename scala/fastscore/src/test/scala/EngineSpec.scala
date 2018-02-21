import org.scalatest._
import com.opendatagroup.fastscore.assets._
import Common._

import com.opendatagroup.fastscore.fleet._

class EngineSpec extends FlatSpec with Matchers with BeforeAndAfterEach {
    implicit var proxy: Proxy = null
    var engine: Engine = null

    override def beforeEach(): Unit = {
        this.proxy = new Proxy(PROXY_PREFIX)
        this.engine = new Engine(ENGINE_NAME)
        this.engine.reset
    }

    "Engine" should "contain an implicit proxy parameter" in {
        engine.proxy should be (proxy)
        proxy.prefix_=("https://localhost:8000")
        engine.proxy.basePath should be (proxy.basePath)
    }

    "Engine.toString" should "return the name of the instance" in {
        engine.toString should be (ENGINE_NAME)
    }

    "Engine.state" should "return the state of the engine" in {
        engine.state should be ("init")
    }

    "Engine.loadModel" should "load a model into the engine" in {
        engine.model should be (None)
        engine.loadModel(model)
        engine.model.get.source should be (model.source)
    }

    "Engine.unloadModel" should "clear the active model" in {
        engine.model should be (None)
        engine.loadModel(model)
        engine.model.get.source should be (model.source)
        engine.unloadModel
        engine.model should be (None)
    }

    "Engine.attachStream" should "attach a stream into the engine" in {
        engine.state should be ("init")
        engine.loadModel(model)
        engine.attachStream(0, rest)
        engine.attachStream(1, rest)
        engine.state should be ("running")
    }
}
