import org.scalatest._

import com.opendatagroup.fastscore.fleet._

class ModelManageSpec extends FlatSpec with Matchers {
    "ModelManage" should "contain an implicit proxy parameter" in {
        implicit val proxy = new Proxy("https://127.0.0.1:8000")
        val modelmanage = new ModelManage("model-manage")
        modelmanage.proxy should be (proxy)
        proxy.prefix_=("https://localhost:8000")
        modelmanage.proxy.basePath should be (proxy.basePath)
    }
}
