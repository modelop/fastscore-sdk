package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet.ModelManage
import com.opendatagroup.fastscore.util._

/** A live collection of sensors in ModelManage
  *
  * @param mm ModelManage instance
  */
class SensorBag(mm: ModelManage) extends Bag[SensorMetadata, Sensor] {
    val modelmanage = mm

    /** Returns a list of sensor names
      *
      * @return list of sensor names
      */
    def names(): List[String] = mm.v1.sensorList(mm.toString) match {
        case Some(sensors) => sensors.map(_.toString)
        case None => List()
    }

    /** Save a sensor to ModelManage
      *
      * @param name sensor name in ModelManage
      * @param sensor sensor object
      */
    def put(name: String, sensor: Sensor): Unit = {
        modelmanage.v1.sensorPut(modelmanage.toString, name, sensor.toString)
    }

    /** List of sensors
      *
      * @return list of sensors
      */
    def iterator = {
        mm.v1.sensorList(mm.toString) match {
            case Some(sensors) =>
                sensors.iterator
                .map { name => SensorMetadata(name, mm) }
            case None => throw FastScoreError("Unexpected response from ModelManage")
        }
    }
}
