package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.util.FastScoreError

import scala.util.matching.Regex

class Proxy(
    prefix: String
) {
    private val serviceExtension = "api/1/service"
    private val validWithoutSlash = "https:\\/\\/((([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\\-]*[A-Za-z0-9])|(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])):[0-9]{4,4}".r
    private val validWithSlash = "https:\\/\\/((([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\\-]*[A-Za-z0-9])|(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])):[0-9]{4,4}\\/".r
    private def constructBasePath(prefix: String): String = {
        prefix match {
            case validWithoutSlash(_*) =>
                s"$prefix/$serviceExtension"
            case validWithSlash(_*) =>
                s"$prefix$serviceExtension"
            case _ =>
                throw FastScoreError("Malformed proxy prefix")
        }
    }

    var basePath = constructBasePath(prefix)

    def prefix_=(prefix: String) = {
        this.basePath = constructBasePath(prefix)
    }
}
