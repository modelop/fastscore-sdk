package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet.ModelManage
import com.opendatagroup.fastscore.util._

class SensorBag(mm: ModelManage) extends Bag[SensorMetadata, Sensor] {
    val modelmanage = mm

    def names(): List[String] = mm.v1.sensorList(mm.toString) match {
        case Some(sensors) => sensors.map(_.toString)
        case None => List()
    }

    def put(name: String, sensor: Sensor): Unit = {
        modelmanage.v1.sensorPut(modelmanage.toString, name, sensor.toString)
    }

    def iterator = {
        mm.v1.sensorList(mm.toString) match {
            case Some(sensors) =>
                sensors.iterator
                .map { name => SensorMetadata(name, mm) }
            case None => throw FastScoreError("Unexpected response from ModelManage")
        }
    }
}
