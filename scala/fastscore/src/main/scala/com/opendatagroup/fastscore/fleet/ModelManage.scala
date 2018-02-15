package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.Constants._
import com.opendatagroup.fastscore.swagger.api1.{ ModelManageApi => ModelManageApi1 }
import com.opendatagroup.fastscore.swagger.api2.{ ModelManageApi => ModelManageApi2 }

/** Model Manage classes
  *
  * ==Overview==
  * The main class to use is [[com.opendatagroup.fastscore.fleet.ModelManage]]
  * This is a reference to a running ModelManage instance.
  * It can be created the following ways:
  * 1. From a Connect object:
  * {{{
  *     scala> implicit val proxy = new Proxy("https://localhost:8000")
  *     scala> val connect = new Connect()
  *     scala> val modelmanage = Connect.get("model-manage-1") match { case Some(mm): Option[ModelManage] => mm }
  * }}}
  * 2. Directly:
  * {{{
  *     scala> implicit val proxy = new Proxy("https://localhost:8000")
  *     scala> val modelmanage = new ModelManage("model-manage-1")
  * }}}
  */
class ModelManage(name: String)(
    implicit val proxy: Proxy
) extends Instance {

    override def toString = name

    val v1 = new ModelManageApi1(proxy.basePath) with SwaggerBase1
    val v2 = new ModelManageApi2(proxy.basePath) with SwaggerBase2

    /** Retrieve an active reference to the models stored in the instance
      *
      */
    lazy val models = new ModelBag(this)

    /** Retrieve an active reference to the schemas stored in the instance
      *
      */
    lazy val schemas = new SchemaBag(this)
    /** Synonym for schemas
      *
      */
    lazy val schemata = schemas

    /** Retrieve an active reference to the streams stored in the instance
      *
      */
    lazy val streams = new StreamBag(this)

    /** Retrieve an active reference to the sensors stored in the instance
      *
      */
    lazy val sensors = new SensorBag(this)
}