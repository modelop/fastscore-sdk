package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.util.SSLVerify._
import com.opendatagroup.fastscore.util.FastScoreError

import com.opendatagroup.fastscore.swagger.models1.{ HealthInfo }
import com.opendatagroup.fastscore.swagger.models2.{ InlineResponse200 => InlineResponse200_2, ActiveSensorInfo, SensorDescriptor }

/** Base trait for an instances /v1 interface
  *
  */
trait SwaggerBase1 {
    def healthGet(instance: String): Option[HealthInfo]
    def swaggerGet(instance: String, accept: Option[String] = None): Option[Any]
}

/** Base trat for an instances /v2 interface
  *
  */
trait SwaggerBase2 {
    def activeSensorList(instance: String): Option[List[ActiveSensorInfo]]
    def activeSensorPoints(instance: String): Option[List[String]]
    def activeSensorInstall(instance: String, desc: SensorDescriptor): Option[InlineResponse200_2]
    def activeSensorUninstall(instance: String, tapId: Integer): Any
}

/** FastScore instance parent trait
  *
  */

trait Instance {
    disableSSLVerify

    def v1: SwaggerBase1
    def v2: SwaggerBase2

    def toString: String

    /** Retrieve the health of the instance
      *
      * @return
      */
    def health: HealthInfo = {
        v1.healthGet(this.toString) match {
            case Some(health) => health
            case None => throw FastScoreError("Empty health info")
        }
    }

    /** Retrieve the swagger spec
      *
      * @return
      */
    def swagger: Option[Any] = {
        v1.swaggerGet(this.toString)
    }

    /** Retrieve a list of active sensors
      *
      * @return
      */
    def activeSensors: List[ActiveSensorInfo] = {
        v2.activeSensorList(this.toString) match {
            case Some(sensorList) => sensorList
            case None => throw FastScoreError("Empty sensor list")
        }
    }

    /** Retrieve a list of tapping points
      *
      * @return
      */
    def tappingPoints: List[String] = {
        v2.activeSensorPoints(this.toString) match {
            case Some(tappingPoints) => tappingPoints
            case None => throw FastScoreError("Empty tapping point list")
        }
    }

    /** Install a sensor
      *
      * @param desc
      * @return
      */
    def installSensor(desc: SensorDescriptor): InlineResponse200_2 = {
        v2.activeSensorInstall(this.toString, desc) match {
            case Some(result) => result
            case None => throw FastScoreError("Empty response")
        }
    }

    /** Uninstall a sensor
      *
      * @param tapId
      * @return
      */
    def uninstallSensor(tapId: Integer): Any = {
        v2.activeSensorUninstall(this.toString, tapId)
    }
}
