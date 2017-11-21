package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet.ModelManage
import com.opendatagroup.fastscore.util._

import scala.util.{ Try, Success, Failure }

trait Asset[T] {
    val name: String

    def get: T
    def delete: Unit
}

trait Bag[Meta, Value] extends Iterable[Meta with Asset[Value]] {
    val modelmanage: ModelManage

    def names(): List[String]
    def iterator: Iterator[Meta with Asset[Value]]

    def get(name: String): Option[Value] = {
        this.iterator.filter { asset => asset.name == name }.toList match {
            case l if l.length == 1 => Some(l(0).get)
            case l if l.length > 1 => throw FastScoreError(s"Ambiguous reference to asset: $name")
            case _ => None
        }
    }

    def remove(name: String): Unit = {
        this.iterator.filter { asset => asset.name == name }.toList match {
            case l if l.length == 1 =>
                l(0).delete
            case l if l.length > 1 => FastScoreError(s"Ambiguous reference to asset: $name")
            case _ => FastScoreError(s"Asset $name not found")
        }
    }
}
