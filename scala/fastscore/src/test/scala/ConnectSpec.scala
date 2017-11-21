import org.scalatest._

import com.opendatagroup.fastscore.fleet._

class ConnectSpec extends FlatSpec with Matchers {
    "Connect" should "contain an implicit proxy parameter" in {
        implicit val proxy = new Proxy("https://127.0.0.1:8000")
        val connect = new Connect
        connect.proxy should be (proxy)
        proxy.prefix_=("https://localhost:8000")
        connect.proxy.basePath should be (proxy.basePath)
    }

    "Connect.get" should "return itself when called with \"connect\"" in {
        implicit val proxy = new Proxy("https://127.0.0.1:8000")
        val connect = new Connect
        connect.get("connect").get should be (connect)
    }

    it should "return an instance if it's name matches the given name" in {
        implicit val proxy = new Proxy("https://127.0.0.1:8000")
        val connect = new Connect
        connect.get("engine-1").get.toString should be ("engine-1")
        connect.get("model-manage-1").get.toString should be ("model-manage-1")
        connect.get("engine") should be (None)
        connect.get("model-manage") should be (None)
    }

    "Connect.lookup" should "return an instance if it's name contains the given query" in {
        implicit val proxy = new Proxy("https://127.0.0.1:8000")
        val connect = new Connect
        connect.lookup("engine-1")(0).toString should be ("engine-1")
        connect.lookup("model-manage-1")(0).toString should be ("model-manage-1")
        connect.lookup("engine")(0).toString should be ("engine-1")
        connect.lookup("model-manage")(0).toString should be ("model-manage-1")
    }
}
