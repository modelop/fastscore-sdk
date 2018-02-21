import org.scalatest._

import com.opendatagroup.fastscore.fleet._
import Common._

class ModelManageSpec extends FlatSpec with Matchers with BeforeAndAfterEach {
    implicit var proxy: Proxy = null
    var modelmanage: ModelManage = null

    override def beforeEach(): Unit = {
        this.proxy = new Proxy(PROXY_PREFIX)
        this.modelmanage = new ModelManage(MODELMANAGE_NAME)
    }


    "ModelManage" should "contain an implicit proxy parameter" in {
        modelmanage.proxy should be (proxy)
        proxy.prefix_=("https://localhost:8000")
        modelmanage.proxy.basePath should be (proxy.basePath)
    }

    "ModelManage.toString" should "return the name of the instance" in {
        modelmanage.toString should be (MODELMANAGE_NAME)
    }

    "ModelManage.models" should "return a model bag" in {
        val models = modelmanage.models
        models.modelmanage should be (modelmanage)
    }

    "ModelManage.streams" should "return a stream bag" in {
        val streams = modelmanage.streams
        streams.modelmanage should be (modelmanage)
    }

    "ModelManage.schemas" should "return a schema bag" in {
        val schemas = modelmanage.schemas
        schemas.modelmanage should be (modelmanage)
    }

    "ModelManage.schemata" should "return a schema bag" in {
        val schemas = modelmanage.schemata
        schemas.modelmanage should be (modelmanage)
    }

    "ModelManage.sensors" should "return a sensor bag" in {
        val sensors = modelmanage.sensors
        sensors.modelmanage should be (modelmanage)
    }
}
