package com.opendatagroup.fastscore.fleet

import com.opendatagroup.fastscore.util.SSLVerify._
import com.opendatagroup.fastscore.util.FastScoreError

import com.opendatagroup.fastscore.swagger.models1.{ HealthInfo }
import com.opendatagroup.fastscore.swagger.models2.{ InlineResponse200 => InlineResponse200_2, ActiveSensorInfo, SensorDescriptor }

trait SwaggerBase1 {
    def healthGet(instance: String): Option[HealthInfo]
    def swaggerGet(instance: String, accept: Option[String] = None): Option[Any]
}

trait SwaggerBase2 {
    def activeSensorList(instance: String): Option[List[ActiveSensorInfo]]
    def activeSensorPoints(instance: String): Option[List[String]]
    def activeSensorInstall(instance: String, desc: SensorDescriptor): Option[InlineResponse200_2]
    def activeSensorUninstall(instance: String, tapId: Integer): Any
}

trait Instance {
    disableSSLVerify

    def v1: SwaggerBase1
    def v2: SwaggerBase2

    def toString: String

    def health: HealthInfo = {
        v1.healthGet(this.toString) match {
            case Some(health) => health
            case None => throw FastScoreError("Empty health info")
        }
    }

    def swagger: Option[Any] = {
        v1.swaggerGet(this.toString)
    }

    def activeSensors: List[ActiveSensorInfo] = {
        v2.activeSensorList(this.toString) match {
            case Some(sensorList) => sensorList
            case None => throw FastScoreError("Empty sensor list")
        }
    }

    def tappingPoints: List[String] = {
        v2.activeSensorPoints(this.toString) match {
            case Some(tappingPoints) => tappingPoints
            case None => throw FastScoreError("Empty tapping point list")
        }
    }

    def installSensor(desc: SensorDescriptor): InlineResponse200_2 = {
        v2.activeSensorInstall(this.toString, desc) match {
            case Some(result) => result
            case None => throw FastScoreError("Empty response")
        }
    }

    def uninstallSensor(tapId: Integer): Any = {
        v2.activeSensorUninstall(this.toString, tapId)
    }
}
