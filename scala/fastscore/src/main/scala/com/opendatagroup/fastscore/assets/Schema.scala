package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._

import scala.io.Source
import java.io.{File, PrintWriter}

/** Schema factory
  *
  */
object Schema {
    /** Create a schema object from file
      *
      * @param path schema source path
      * @return schema object
      */
    def fromFile(path: String): Schema = {
        val source = Source.fromFile(path).getLines.mkString
        Schema(source)
    }
}

/** SchemaMetadata companion trait
  *
  */
sealed trait SchemaMetaOps {
    val name: String
    val modelmanage: ModelManage

    /** Retrieve the schema from ModelManage
      *
      * @return schema object
      */
    def get(): Schema = {
        modelmanage.v1.schemaGet(modelmanage.toString, name) match {
            case Some(source) => Schema(source.toString)
            case None => throw FastScoreError("Schema not found")
        }
    }

    /** Delete the schema from ModelManage
      *
      */
    def delete(): Unit = {
        modelmanage.v1.schemaDelete(modelmanage.toString, name)
    }
}

/** SchemaMetadata
  *
  * @param name name of the schema in ModelManage
  * @param modelmanage ModelManage instance
  */
case class SchemaMetadata(
    name: String,
    modelmanage: ModelManage
) extends SchemaMetaOps with Asset[Schema]

/** Schema serializer companion trait
  *
  */
sealed trait SchemaSerializer {
    val source: String

    override def toString(): String = source

    /** Write a schema to file
      *
      * @param path destination path
      */
    def toFile(path: String): Unit = {
        val writer = new PrintWriter(new File(path))
        writer.write(source)
        writer.close
    }
}

/** Schema object
  *
  * @param source schema source
  */
case class Schema(
    source: String
) extends SchemaSerializer