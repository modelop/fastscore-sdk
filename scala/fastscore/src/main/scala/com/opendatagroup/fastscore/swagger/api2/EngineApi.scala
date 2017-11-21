/**
 * FastScore API (proxy)
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * OpenAPI spec version: 1.6
 * 
 *
 * NOTE: This class is auto generated by the swagger code generator program.
 * https://github.com/swagger-api/swagger-codegen.git
 * Do not edit the class manually.
 */

package com.opendatagroup.fastscore.swagger.api2

import com.opendatagroup.fastscore.swagger.models2.ActiveModelInfo
import com.opendatagroup.fastscore.swagger.models2.ActiveSensorInfo
import com.opendatagroup.fastscore.swagger.models2.ActiveStreamInfo
import com.opendatagroup.fastscore.swagger.models2.InlineResponse200
import com.opendatagroup.fastscore.swagger.models2.InlineResponse2001
import com.opendatagroup.fastscore.swagger.models2.Record
import com.opendatagroup.fastscore.swagger.models2.SensorDescriptor
import com.opendatagroup.fastscore.swagger.models2.StreamDescriptor
import com.opendatagroup.fastscore.swagger.invoker2.ApiInvoker
import com.opendatagroup.fastscore.swagger.invoker2.ApiException

import com.sun.jersey.multipart.FormDataMultiPart
import com.sun.jersey.multipart.file.FileDataBodyPart

import javax.ws.rs.core.MediaType

import java.io.File
import java.util.Date

import scala.collection.mutable.HashMap

class EngineApi(val defBasePath: String = "https://localhost/api/1/service",
                        defApiInvoker: ApiInvoker = ApiInvoker) {
  var basePath = defBasePath
  var apiInvoker = defApiInvoker

  def addHeader(key: String, value: String) = apiInvoker.defaultHeaders += key -> value 

  /**
   * 
   * 
   * @param instance instance name 
   * @return void
   */
  def activeModelDelete(instance: String) = {
    // create path and map variables
    val path = "/{instance}/2/active/model".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeModelDelete")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "DELETE", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return ActiveModelInfo
   */
  def activeModelGet(instance: String): Option[ActiveModelInfo] = {
    // create path and map variables
    val path = "/{instance}/2/active/model".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeModelGet")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[ActiveModelInfo]).asInstanceOf[ActiveModelInfo])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param factor jet count 
   * @return void
   */
  def activeModelScale(instance: String, factor: Integer) = {
    // create path and map variables
    val path = "/{instance}/2/active/model/scale".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeModelScale")

    

    var postBody:AnyRef = factor.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param sid schema id 
   * @return void
   */
  def activeSchemaUnverify(instance: String, sid: Integer) = {
    // create path and map variables
    val path = "/{instance}/2/active/schema/verify/{sid}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "sid" + "\\}",apiInvoker.escape(sid))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSchemaUnverify")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "DELETE", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param schema Avro schema 
   * @return InlineResponse200
   */
  def activeSchemaVerify(instance: String, schema: Any): Option[InlineResponse200] = {
    // create path and map variables
    val path = "/{instance}/2/active/schema/verify".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSchemaVerify")

    

    var postBody:AnyRef = schema.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[InlineResponse200]).asInstanceOf[InlineResponse200])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param sid schema id 
   * @param record data record to verify 
   * @return void
   */
  def activeSchemaVerifyData(instance: String, sid: Integer, record: Record) = {
    // create path and map variables
    val path = "/{instance}/2/active/schema/verify/{sid}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "sid" + "\\}",apiInvoker.escape(sid))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSchemaVerifyData")

    if (record == null) throw new Exception("Missing required parameter 'record' when calling EngineApi->activeSchemaVerifyData")

    

    var postBody:AnyRef = record.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param desc sensor descriptor 
   * @return InlineResponse200
   */
  def activeSensorInstall(instance: String, desc: SensorDescriptor): Option[InlineResponse200] = {
    // create path and map variables
    val path = "/{instance}/2/active/sensor".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorInstall")

    if (desc == null) throw new Exception("Missing required parameter 'desc' when calling EngineApi->activeSensorInstall")

    

    var postBody:AnyRef = desc.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[InlineResponse200]).asInstanceOf[InlineResponse200])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return List[ActiveSensorInfo]
   */
  def activeSensorList(instance: String): Option[List[ActiveSensorInfo]] = {
    // create path and map variables
    val path = "/{instance}/2/active/sensor".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorList")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "array", classOf[ActiveSensorInfo]).asInstanceOf[List[ActiveSensorInfo]])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return List[String]
   */
  def activeSensorPoints(instance: String): Option[List[String]] = {
    // create path and map variables
    val path = "/{instance}/2/active/sensor/points".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorPoints")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "array", classOf[String]).asInstanceOf[List[String]])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param tapId installed sensor id 
   * @return void
   */
  def activeSensorUninstall(instance: String, tapId: Integer) = {
    // create path and map variables
    val path = "/{instance}/2/active/sensor/{tap-id}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "tap-id" + "\\}",apiInvoker.escape(tapId))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorUninstall")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "DELETE", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param desc The stream descriptor 
   * @param slot stream slot number 
   * @param dryRun verificaton only (optional)
   * @param contentDisposition pass stream name (optional)
   * @return Any
   */
  def activeStreamAttach(instance: String, desc: String, slot: Integer, dryRun: Option[Boolean] = None, contentDisposition: Option[String] = None): Option[Any] = {
    // create path and map variables
    val path = "/{instance}/2/active/stream/{slot}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "slot" + "\\}",apiInvoker.escape(slot))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeStreamAttach")

    if (desc == null) throw new Exception("Missing required parameter 'desc' when calling EngineApi->activeStreamAttach")

    dryRun.map(paramVal => queryParams += "dry-run" -> paramVal.toString)
    
    contentDisposition.map(paramVal => headerParams += "Content-Disposition" -> paramVal)

    var postBody:AnyRef = desc.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "PUT", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType, "text/html") match {
        case s: String =>
           Some(s.asInstanceOf[Any])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @param slot stream slot number 
   * @return void
   */
  def activeStreamDetach(instance: String, slot: Integer) = {
    // create path and map variables
    val path = "/{instance}/2/active/stream/{slot}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "slot" + "\\}",apiInvoker.escape(slot))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeStreamDetach")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "DELETE", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return List[ActiveStreamInfo]
   */
  def activeStreamList(instance: String): Option[List[ActiveStreamInfo]] = {
    // create path and map variables
    val path = "/{instance}/2/active/stream".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeStreamList")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "array", classOf[ActiveStreamInfo]).asInstanceOf[List[ActiveStreamInfo]])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return void
   */
  def enginePause(instance: String) = {
    // create path and map variables
    val path = "/{instance}/2/engine/pause".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->enginePause")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return void
   */
  def engineReset(instance: String) = {
    // create path and map variables
    val path = "/{instance}/2/engine/reset".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->engineReset")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return InlineResponse2001
   */
  def engineStateGet(instance: String): Option[InlineResponse2001] = {
    // create path and map variables
    val path = "/{instance}/2/engine/state".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->engineStateGet")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[InlineResponse2001]).asInstanceOf[InlineResponse2001])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

  /**
   * 
   * 
   * @param instance instance name 
   * @return void
   */
  def engineUnpause(instance: String) = {
    // create path and map variables
    val path = "/{instance}/2/engine/unpause".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->engineUnpause")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
                  case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

}
