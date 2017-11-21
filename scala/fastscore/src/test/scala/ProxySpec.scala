import org.scalatest._

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._

import scala.util.{ Try, Success, Failure }

class ProxySpec extends FlatSpec with Matchers {
    "Proxy" should "accept a correctly-formatted IP address" in {
        val proxy = new Proxy("https://127.0.0.1:8000")
        proxy.basePath should be ("https://127.0.0.1:8000/api/1/service")
    }

    it should "accept a correctly-formatted hostname" in {
        val proxy = new Proxy("https://localhost:8000")
        proxy.basePath should be ("https://localhost:8000/api/1/service")
        val proxy2 = new Proxy("https://example.com:8000")
        proxy2.basePath should be ("https://example.com:8000/api/1/service")
    }

    it should "throw an error if passed an incorrectly-formatted IP address" in {
        val proxyTry = Try(new Proxy("https://1234.123.123.13.2:8000"))
        proxyTry should be (Failure(FastScoreError("Malformed proxy prefix")))
    }

    it should "throw an error if passed an incorrectly-formatted hostname" in {
        val proxyTry = Try(new Proxy("https://example com:8000"))
        proxyTry should be (Failure(FastScoreError("Malformed proxy prefix")))
    }

    it should "throw an error if passed a prefix with a non-HTTPS scheme" in {
        Try(new Proxy("http://example.com:8000")) should be (Failure(FastScoreError("Malformed proxy prefix")))
        Try(new Proxy("ws://example.com:8000")) should be (Failure(FastScoreError("Malformed proxy prefix")))
        Try(new Proxy("sftp://example.com:8000")) should be (Failure(FastScoreError("Malformed proxy prefix")))
    }
}
