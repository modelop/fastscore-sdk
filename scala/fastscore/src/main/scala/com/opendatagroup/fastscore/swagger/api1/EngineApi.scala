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

package com.opendatagroup.fastscore.swagger.api1

import com.opendatagroup.fastscore.swagger.models1.CpuUsageInfo
import com.opendatagroup.fastscore.swagger.models1.HealthInfo
import com.opendatagroup.fastscore.swagger.models1.InlineResponse200
import com.opendatagroup.fastscore.swagger.models1.InlineResponse2001
import com.opendatagroup.fastscore.swagger.models1.InlineResponse2002
import com.opendatagroup.fastscore.swagger.models1.InlineResponse2003
import com.opendatagroup.fastscore.swagger.models1.ManifoldInfo
import com.opendatagroup.fastscore.swagger.models1.VerifyInfo
import com.opendatagroup.fastscore.swagger.invoker1.ApiInvoker
import com.opendatagroup.fastscore.swagger.invoker1.ApiException

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
   * @param desc sensor descriptor 
   * @return InlineResponse2001
   */
  def activeSensorAttach(instance: String, desc: Any): Option[InlineResponse2001] = {
    // create path and map variables
    val path = "/{instance}/1/control/sensor".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorAttach")

    

    var postBody:AnyRef = desc.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
   * @return List[String]
   */
  def activeSensorAvailable(instance: String): Option[List[String]] = {
    // create path and map variables
    val path = "/{instance}/1/control/sensor/available".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorAvailable")

    

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
   * @param tapId The identifier of the sensor connection 
   * @return InlineResponse2002
   */
  def activeSensorDescribe(instance: String, tapId: Integer): Option[InlineResponse2002] = {
    // create path and map variables
    val path = "/{instance}/1/control/sensor/{tap-id}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "tap-id" + "\\}",apiInvoker.escape(tapId))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorDescribe")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[InlineResponse2002]).asInstanceOf[InlineResponse2002])
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
   * @param tapId The identifier of the sensor connection 
   * @return void
   */
  def activeSensorDetach(instance: String, tapId: Integer) = {
    // create path and map variables
    val path = "/{instance}/1/control/sensor/{tap-id}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "tap-id" + "\\}",apiInvoker.escape(tapId))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->activeSensorDetach")

    

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
   * @return List[InlineResponse200]
   */
  def activeSensorList(instance: String): Option[List[InlineResponse200]] = {
    // create path and map variables
    val path = "/{instance}/1/control/sensor".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

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
           Some(apiInvoker.deserialize(s, "array", classOf[InlineResponse200]).asInstanceOf[List[InlineResponse200]])
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
   * @return HealthInfo
   */
  def healthGet(instance: String): Option[HealthInfo] = {
    // create path and map variables
    val path = "/{instance}/1/health".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->healthGet")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[HealthInfo]).asInstanceOf[HealthInfo])
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
   * @param stream The input stream descriptor 
   * @return void
   */
  def inputStreamSet(instance: String, stream: Any) = {
    // create path and map variables
    val path = "/{instance}/1/job/stream/in".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->inputStreamSet")

    

    var postBody:AnyRef = stream.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "PUT", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
  def jobDelete(instance: String) = {
    // create path and map variables
    val path = "/{instance}/1/job".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobDelete")

    

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
   * @param data Input data 
   * @param slot The stream slot 
   * @return void
   */
  def jobIoInput(instance: String, data: String, slot: String) = {
    // create path and map variables
    val path = "/{instance}/1/job/input/{slot}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "slot" + "\\}",apiInvoker.escape(slot))

    val contentTypes = List("application/octet-stream")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobIoInput")

    if (data == null) throw new Exception("Missing required parameter 'data' when calling EngineApi->jobIoInput")

    if (slot == null) throw new Exception("Missing required parameter 'slot' when calling EngineApi->jobIoInput")

    

    var postBody:AnyRef = data.asInstanceOf[AnyRef]

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
  def jobIoInput0(instance: String) = {
    // create path and map variables
    val path = "/{instance}/1/job/input".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobIoInput0")

    

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
   * @param slot The stream slot 
   * @return String
   */
  def jobIoOutput(instance: String, slot: String): Option[String] = {
    // create path and map variables
    val path = "/{instance}/1/job/output/{slot}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "slot" + "\\}",apiInvoker.escape(slot))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobIoOutput")

    if (slot == null) throw new Exception("Missing required parameter 'slot' when calling EngineApi->jobIoOutput")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[String]).asInstanceOf[String])
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
  def jobIoOutput1(instance: String) = {
    // create path and map variables
    val path = "/{instance}/1/job/output".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobIoOutput1")

    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
   * @param duration The number of seconds to sample CPU usage for (optional)
   * @return CpuUsageInfo
   */
  def jobSampleCpu(instance: String, duration: Option[Integer] = None): Option[CpuUsageInfo] = {
    // create path and map variables
    val path = "/{instance}/1/job/sample/cpu".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobSampleCpu")

    duration.map(paramVal => queryParams += "Duration" -> paramVal.toString)
    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[CpuUsageInfo]).asInstanceOf[CpuUsageInfo])
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
   * @param n The number of jets to scale model to 
   * @return void
   */
  def jobScale(instance: String, n: Integer) = {
    // create path and map variables
    val path = "/{instance}/1/job/scale".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobScale")

    queryParams += "n" -> n.toString
    

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
   * @param state The model state blob 
   * @return void
   */
  def jobStateRestore(instance: String, state: String) = {
    // create path and map variables
    val path = "/{instance}/1/job/state".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/octet-stream")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobStateRestore")

    if (state == null) throw new Exception("Missing required parameter 'state' when calling EngineApi->jobStateRestore")

    

    var postBody:AnyRef = state.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "PUT", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
   * @param fields A comma-separated list of field names (slots, jets, snapshots, state) (optional)
   * @return ManifoldInfo
   */
  def jobStatus(instance: String, fields: Option[String] = None): Option[ManifoldInfo] = {
    // create path and map variables
    val path = "/{instance}/1/job/status".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->jobStatus")

    fields.map(paramVal => queryParams += "return" -> paramVal.toString)
    

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[ManifoldInfo]).asInstanceOf[ManifoldInfo])
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
   * @param data model+attachments 
   * @param dryRun verificaton only (optional)
   * @param _contentType model MIME type (optional)
   * @param contentDisposition pass model name (optional)
   * @return VerifyInfo
   */
  def modelLoad(instance: String, data: String, dryRun: Option[Boolean] = None, _contentType: Option[String] = None, contentDisposition: Option[String] = None): Option[VerifyInfo] = {
    // create path and map variables
    val path = "/{instance}/1/job/model".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentType = if (_contentType.isDefined) _contentType.get else "application/json"

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->modelLoad")

    if (data == null) throw new Exception("Missing required parameter 'data' when calling EngineApi->modelLoad")

    dryRun.map(paramVal => queryParams += "dry-run" -> paramVal.toString)
    
    _contentType.map(paramVal => headerParams += "Content-Type" -> paramVal)
    contentDisposition.map(paramVal => headerParams += "Content-Disposition" -> paramVal)

    var postBody:AnyRef = data.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "PUT", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType, "text/html") match {
        case s: String =>
           Some(VerifyInfo(None, None, None, None, None))
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
  def modelUnload(instance: String) = {
    // create path and map variables
    val path = "/{instance}/1/job/model".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->modelUnload")

    

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
   * @param stream The output stream descriptor 
   * @return void
   */
  def outputStreamSet(instance: String, stream: String) = {
    // create path and map variables
    val path = "/{instance}/1/job/stream/out".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->outputStreamSet")

    if (stream == null) throw new Exception("Missing required parameter 'stream' when calling EngineApi->outputStreamSet")

    

    var postBody:AnyRef = stream.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "PUT", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
   * @param accept Force Accept header value (optional)
   * @return String
   */
  def policyGet(instance: String, accept: Option[String] = None): Option[String] = {
    // create path and map variables
    val path = "/{instance}/1/policy".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->policyGet")

    
    accept.map(paramVal => headerParams += "Accept" -> paramVal)

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[String]).asInstanceOf[String])
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
   * @param policy The policy content 
   * @param _contentType model MIME type (optional)
   * @return void
   */
  def policyPut(instance: String, policy: String, _contentType: Option[String] = None) = {
    // create path and map variables
    val path = "/{instance}/1/policy".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->policyPut")

    if (policy == null) throw new Exception("Missing required parameter 'policy' when calling EngineApi->policyPut")

    
    _contentType.map(paramVal => headerParams += "Content-Type" -> paramVal)

    var postBody:AnyRef = policy.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "PUT", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
   * @return List[String]
   */
  def scoopDebugOutput(instance: String): Option[List[String]] = {
    // create path and map variables
    val path = "/{instance}/1/debug/output".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->scoopDebugOutput")

    

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
   * @param slot The stream slot 
   * @param stream The input/output stream descriptor 
   * @return void
   */
  def streamAttach(instance: String, slot: String, stream: String) = {
    // create path and map variables
    val path = "/{instance}/1/job/stream/{slot}".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance)).replaceAll("\\{" + "slot" + "\\}",apiInvoker.escape(slot))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->streamAttach")

    if (slot == null) throw new Exception("Missing required parameter 'slot' when calling EngineApi->streamAttach")

    if (stream == null) throw new Exception("Missing required parameter 'stream' when calling EngineApi->streamAttach")

    

    var postBody:AnyRef = stream.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "PUT", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
   * @param stream The stream descriptor to measure data rate 
   * @return List[InlineResponse2003]
   */
  def streamRate(instance: String, stream: String): Option[List[InlineResponse2003]] = {
    // create path and map variables
    val path = "/{instance}/1/stream/rate".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->streamRate")

    if (stream == null) throw new Exception("Missing required parameter 'stream' when calling EngineApi->streamRate")

    

    var postBody:AnyRef = stream.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "array", classOf[InlineResponse2003]).asInstanceOf[List[InlineResponse2003]])
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
   * @param desc The stream descriptor to get sample data from 
   * @param n The number of data items to read from the stream (optional)
   * @return List[String]
   */
  def streamSample(instance: String, desc: String, n: Option[Integer] = None): Option[List[String]] = {
    // create path and map variables
    val path = "/{instance}/1/stream/sample".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->streamSample")

    if (desc == null) throw new Exception("Missing required parameter 'desc' when calling EngineApi->streamSample")

    n.map(paramVal => queryParams += "n" -> paramVal.toString)
    

    var postBody:AnyRef = desc.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "POST", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
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
   * @param accept Force Accept header value (optional)
   * @return Any
   */
  def swaggerGet(instance: String, accept: Option[String] = None): Option[Any] = {
    // create path and map variables
    val path = "/{instance}/1/swagger".replaceAll("\\{format\\}", "json").replaceAll("\\{" + "instance" + "\\}",apiInvoker.escape(instance))

    val contentTypes = List("application/json")
    val contentType = contentTypes(0)

    val queryParams = new HashMap[String, String]
    val headerParams = new HashMap[String, String]
    val formParams = new HashMap[String, String]

    if (instance == null) throw new Exception("Missing required parameter 'instance' when calling EngineApi->swaggerGet")

    
    accept.map(paramVal => headerParams += "Accept" -> paramVal)

    var postBody:AnyRef = null.asInstanceOf[AnyRef]

    if (contentType.startsWith("multipart/form-data")) {
      val mp = new FormDataMultiPart
      postBody = mp
    } else {
    }

    try {
      apiInvoker.invokeApi(basePath, path, "GET", queryParams.toMap, formParams.toMap, postBody, headerParams.toMap, contentType) match {
        case s: String =>
           Some(apiInvoker.deserialize(s, "", classOf[Any]).asInstanceOf[Any])
        case _ => None
      }
    } catch {
      case ex: ApiException if ex.code == 404 => None
      case ex: ApiException => throw ex
    }
  }

}