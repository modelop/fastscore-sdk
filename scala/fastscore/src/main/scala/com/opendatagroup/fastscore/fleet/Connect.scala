package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore._
import com.opendatagroup.fastscore.swagger.api1.{ ConnectApi => ConnectApi1 }
import com.opendatagroup.fastscore.swagger.api2.{ ConnectApi => ConnectApi2 }
import com.opendatagroup.fastscore.util.FastScoreError

import com.opendatagroup.fastscore.swagger.models1._

import scala.collection.mutable.{ HashMap => MutMap }

class Connect(
    implicit val proxy: Proxy
) extends Instance {

    override def toString = "connect"

    val v1 = new ConnectApi1(proxy.basePath) with SwaggerBase1
    val v2 = new ConnectApi2(proxy.basePath) with SwaggerBase2

    val instanceCache: MutMap[String, Instance] = new MutMap()

    var target: String = this.toString

    def fleet(): List[Instance] = {
        v1.connectGet("connect") match {
            case Some(instances) =>
                instances.map { instance => instance.api match {
                    case Some("connect") => new Connect with Instance
                    case Some("model-manage") => new ModelManage(instance.name.get) with Instance
                    case Some("engine") => new Engine(instance.name.get) with Instance
                    case _ => throw FastScoreError("Unexpected response from connect")
                }}
            case None => List()
        }
    }

    def lookup(query: String): List[Instance] = {
        if (query == "connect") List(this) else {

        instanceCache.filter { case (name, _) => name.contains(query) }.toList match {
            case l: List[(String, Instance)] if l.length >= 1 => l.map { case (_, i) => i }
            case _ =>
                fleet match { case instances: List[Instance] =>
                    instances.foreach { i => instanceCache += (i.toString -> i) }
                    instances.filter(i => i.toString.contains(query))
                }
        }}
    }

    def get(name: String): Option[Instance] = {
        if (name == "connect") Some(this) else {

        instanceCache.get(name) match {
            case Some(instance) => Some(instance)
            case None =>
                fleet match { case instances: List[Instance] =>
                    instances.foreach { i => instanceCache += (i.toString -> i) }
                    instances.filter(i => i.toString == name) match {
                        case l: List[Instance] if l.length == 1 => Some(l(0))
                        case l: List[Instance] if l.length > 1 => throw FastScoreError(s"Ambiguous reference to instance: $name")
                        case _ => None
                    }
                }
        }}
    }
}
