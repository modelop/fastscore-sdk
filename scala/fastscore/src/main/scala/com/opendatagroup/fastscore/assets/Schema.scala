package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._

import scala.io.Source
import java.io.{File, PrintWriter}

object Schema {
    def fromFile(path: String): Schema = {
        val source = Source.fromFile(path).getLines.mkString
        Schema(source)
    }
}

sealed trait SchemaMetaOps {
    val name: String
    val modelmanage: ModelManage

    def get(): Schema = {
        modelmanage.v1.schemaGet(modelmanage.toString, name) match {
            case Some(source) => Schema(source.toString)
            case None => throw FastScoreError("Schema not found")
        }
    }

    def delete(): Unit = {
        modelmanage.v1.schemaDelete(modelmanage.toString, name)
    }
}

case class SchemaMetadata(
    name: String,
    modelmanage: ModelManage
) extends SchemaMetaOps with Asset[Schema]


sealed trait SchemaSerializer {
    val source: String

    override def toString(): String = source

    def toFile(path: String): Unit = {
        val writer = new PrintWriter(new File(path))
        writer.write(source)
        writer.close
    }
}

case class Schema(
    source: String
) extends SchemaSerializer