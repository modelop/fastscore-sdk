package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet.ModelManage
import com.opendatagroup.fastscore.util._

/** A live collection of schemas in ModelManage
  *
  * @param mm ModelManage instance
  */
class SchemaBag(mm: ModelManage) extends Bag[SchemaMetadata, Schema] {
    val modelmanage = mm

    /** Returns a list of schema names
      *
      * @return list of schema names
      */
    def names(): List[String] = mm.v1.schemaList(mm.toString) match {
        case Some(schema) => schema.map(_.toString)
        case None => List()
    }

    /** Save a schema to ModelManage
      *
      * @param name schema name in ModelManage
      * @param schema schema object
      */
    def put(name: String, schema: Schema): Unit = {
        modelmanage.v1.schemaPut(modelmanage.toString, name, schema.toString)
    }

    /** List of schemas
      *
      * @return list of schemas
      */
    def iterator = {
        mm.v1.schemaList(mm.toString) match {
            case Some(schema) =>
                schema.iterator
                .map { name => SchemaMetadata(name, mm) }
            case None => throw FastScoreError("Unexpected response from ModelManage")
        }
    }
}
