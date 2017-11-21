package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.Constants._
import com.opendatagroup.fastscore.swagger.api1.{ ModelManageApi => ModelManageApi1 }
import com.opendatagroup.fastscore.swagger.api2.{ ModelManageApi => ModelManageApi2 }

class ModelManage(name: String)(
    implicit val proxy: Proxy
) extends Instance {

    override def toString = name

    val v1 = new ModelManageApi1(proxy.basePath) with SwaggerBase1
    val v2 = new ModelManageApi2(proxy.basePath) with SwaggerBase2

    lazy val models = new ModelBag(this)

    lazy val schemas = new SchemaBag(this)
    lazy val schemata = schemas

    lazy val streams = new StreamBag(this)

    lazy val sensors = new SensorBag(this)
}