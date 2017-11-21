import org.scalatest._

import com.opendatagroup.fastscore.fleet._

class EngineSpec extends FlatSpec with Matchers {
    "Engine" should "contain an implicit proxy parameter" in {
        implicit val proxy = new Proxy("https://127.0.0.1:8000")
        val engine = new Engine("engine")
        engine.proxy should be (proxy)
        proxy.prefix_=("https://localhost:8000")
        engine.proxy.basePath should be (proxy.basePath)
    }
}
