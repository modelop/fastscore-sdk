package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet.ModelManage
import com.opendatagroup.fastscore.util._

class SchemaBag(mm: ModelManage) extends Bag[SchemaMetadata, Schema] {
    val modelmanage = mm
    def names(): List[String] = mm.v1.schemaList(mm.toString) match {
        case Some(schema) => schema.map(_.toString)
        case None => List()
    }

    def put(name: String, schema: Schema): Unit = {
        modelmanage.v1.schemaPut(modelmanage.toString, name, schema.toString)
    }

    def iterator = {
        mm.v1.schemaList(mm.toString) match {
            case Some(schema) =>
                schema.iterator
                .map { name => SchemaMetadata(name, mm) }
            case None => throw FastScoreError("Unexpected response from ModelManage")
        }
    }
}
