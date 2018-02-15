package com.opendatagroup.fastscore.assets
/** Model classes
  *
  *   ==Overview==
  *   The main class is [[com.opendatagroup.fastscore.assets.Model]].
  *   It contains the name, the format and the source code of the model.
  *   A model object can be obtained the following ways:
  *   1. From ModelManage
  *      {{{
  *          scala> // From ModelManage
  *          scala> val mm: ModelManage = ...
  *          scala> val model = mm.models.get("model-1") match { case Some(m) => m }
  *      }}}
  *   2. From File
  *      {{{
  *          scala> val m = Model.fromFile(PATH)
  *      }}}
  */

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._
import com.opendatagroup.fastscore.assets.Constants._

import scala.io.Source
import java.io.{File, PrintWriter}

/** Model factory
  *
  */
object Model {
    private val ext = """\.[A-Za-z0-9]+$""".r

    /** Create Model object from file
      *
      * Model Format is detected from file extension if not provided
      *
      * @param path model source path
      * @param format model format
      * @return
      */
    def fromFile(path: String, format: Option[String] = None): Model = {
        format match {
            case Some(format) =>
                if (MODEL_CONTENT_TYPES.get(format).isEmpty)
                    throw FastScoreError(s"Model format not found: $format")
                val source = Source.fromFile(path).getLines.mkString
                Model(format, source, ModelParseOps.extractSchemas(format, source))
            case None =>
                ext.findFirstIn(path) match {
                    case Some(ext) =>
                        MODEL_FORMAT_EXT.get(ext) match {
                            case Some(format) =>
                                val source = Source.fromFile(path).getLines.mkString("\n")
                                Model(format, source, ModelParseOps.extractSchemas(format, source))
                            case None => throw FastScoreError(s"Unable to extract model format from file extension")
                        }
                    case None => throw FastScoreError("Unable to extract file extension, please specify format explicitly")
                }
        }
    }
}

/** Model Parsing helper functions
  *
  */
object ModelParseOps {
    /** Extract schemas from Smart Comments in the Model source
      *
      * @param format model format
      * @param source model source
      * @return slot => schema map
      */
    def extractSchemas(format: String, source: String): Map[Int, String] = {
        format match {
            case "pfa-json" => throw FastScoreError("Not implemented")
            case "pfa->yaml" => throw FastScoreError("Not implemented")
            case "pfa->pretty" => throw FastScoreError("Not implemented")
            case "python" | "python3" | "R" =>
                val exp = "s*(fastscore|odg)\\.(\\S*)\\s*:\\s*(\\S*)\\s*".r
                exp.findAllMatchIn(source)
                    .filter(v => v.subgroups(1).split('.')(0) == "schema")
                    .map( v => (v.subgroups(1).split('.')(1).toInt, v.subgroups(2))).toMap
            case "java" => throw FastScoreError("Not implemented")
            case "c" => throw FastScoreError("Not implemented")
            case "octave" => throw FastScoreError("Not implemented")
        }
    }
}

/** ModelMetadata companion trait
  *
  */
sealed trait ModelMetaOps {
    val name: String
    val format: String
    val modelmanage: ModelManage

    /** Retrieve the Model from ModelManage
      *
      * @return Model object
      */
    def get(): Model = {
        modelmanage.v1.modelGet(modelmanage.toString, name) match {
            case Some(source) =>
                Model(format, source, ModelParseOps.extractSchemas(format, source))
            case None => throw FastScoreError("Model not found")
        }
    }

    /** Delete the Model from ModelManage
      *
      */
    def delete(): Unit = {
        modelmanage.v1.modelDelete(modelmanage.toString, name)
    }
}

/** ModelMetadata
  *
  *  @constructor create a new ModelMetadata object.
  *  @param name model name
  *  @param format model format
  *  @param modelmanage modelmanage instance hosting the model
  */
case class ModelMetadata(
    name: String,
    format: String,
    modelmanage: ModelManage
) extends ModelMetaOps with Asset[Model]


/** Model Serialization companion trait
  */
sealed trait ModelSerializer {
    val format: String
    val source: String

    override def toString: String = source

    /** Saves a Model to file
      *
      * @param path destination path
      */
    def toFile(path: String): Unit = {
        val writer = new PrintWriter(new File(path))
        writer.write(source)
        writer.close
    }
}

/** Model
  *
  *  @constructor create a new model object.
  *  @param format model format
  *  @param source model source
  *  @param schema extracted model schema
  */
case class Model(
    format: String,
    source: String,
    schema: Map[Int, String]
) extends ModelSerializer