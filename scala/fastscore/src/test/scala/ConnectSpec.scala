import org.scalatest._
import scala.collection.mutable.{ HashMap => MutMap }
import com.opendatagroup.fastscore.fleet._
import Common._

class ConnectSpec extends FlatSpec with Matchers with BeforeAndAfterEach {
    implicit var proxy: Proxy = null
    var connect: Connect = null

    override def beforeEach(): Unit = {
        this.proxy = new Proxy(PROXY_PREFIX)
        this.connect = new Connect
    }

    "Connect" should "contain an implicit proxy parameter" in {
        connect.proxy should be (proxy)
        proxy.prefix_=("https://localhost:8000")
        connect.proxy.basePath should be (proxy.basePath)
    }

    "Connect.toString" should "return the name of connect" in {
        connect.toString should be ("connect")
    }

    "Connect.target" should "contain the name" in {
        connect.target should be ("connect")
    }

    "Connect.fleet" should "return a list of instances" in {
        val fleetNames: List[String] = connect.fleet.map(_.toString)
        fleetNames.contains("engine-1") should be (true)
        fleetNames.contains("model-manage-1") should be (true)
    }

    "Connect.get" should "return itself when called with \"connect\"" in {
        connect.get("connect").get should be (connect)
    }

    it should "return an instance if it's name matches the given name" in {
        connect.get("engine-1").get.toString should be ("engine-1")
        connect.get("model-manage-1").get.toString should be ("model-manage-1")
        connect.get("engine") should be (None)
        connect.get("model-manage") should be (None)
    }

    it should "cache resolved instances" in {
        connect.instanceCache.contains("engine-1") should be (false)
        connect.get("engine-1")
        connect.instanceCache.contains("engine-1") should be (true)
    }

    "Connect.lookup" should "return itself when called with \"connect\"" in {
        connect.lookup("connect")(0) should be (connect)
    }

    it should "return an instance if it's name contains the given query" in {
        connect.lookup("engine-1")(0).toString should be ("engine-1")
        connect.lookup("model-manage-1")(0).toString should be ("model-manage-1")
        connect.lookup("engine")(0).toString should be ("engine-1")
        connect.lookup("model-manage")(0).toString should be ("model-manage-1")
    }

    it should "cache resolved instances" in {
        connect.instanceCache.contains("engine-1") should be (false)
        connect.lookup("engine")
        connect.instanceCache.contains("engine-1") should be (true)
    }
}
