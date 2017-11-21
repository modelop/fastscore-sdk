package com.opendatagroup.fastscore.assets

import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._
import com.opendatagroup.fastscore.assets.Constants._

import scala.io.Source
import java.io.{File, PrintWriter}

object Model {
    private val ext = """\.[A-Za-z0-9]+$""".r

    def fromFile(path: String, format: Option[String] = None): Model = {
        format match {
            case Some(format) =>
                if (MODEL_CONTENT_TYPES.get(format).isEmpty)
                    throw FastScoreError(s"Model format not found: $format")
                val source = Source.fromFile(path).getLines.mkString
                Model(format, source)
            case None =>
                ext.findFirstIn(path) match {
                    case Some(ext) =>
                        MODEL_FORMAT_EXT.get(ext) match {
                            case Some(format) =>
                                val source = Source.fromFile(path).getLines.mkString("\n")
                                Model(format, source)
                            case None => throw FastScoreError(s"Unable to extract model format from file extension")
                        }
                    case None => throw FastScoreError("Unable to extract file extension, please specify format explicitly")
                }
        }
    }
}

sealed trait ModelMetaOps {
    val name: String
    val format: String
    val modelmanage: ModelManage

    def get(): Model = {
        modelmanage.v1.modelGet(modelmanage.toString, name) match {
            case Some(source) => Model(format, source)
            case None => throw FastScoreError("Model not found")
        }
    }

    def delete(): Unit = {
        modelmanage.v1.modelDelete(modelmanage.toString, name)
    }
}

case class ModelMetadata(
    name: String,
    format: String,
    modelmanage: ModelManage
) extends ModelMetaOps with Asset[Model]

sealed trait ModelSerializer {
    val format: String
    val source: String

    override def toString: String = source

    def toFile(path: String): Unit = {
        val writer = new PrintWriter(new File(path))
        writer.write(source)
        writer.close
    }
}

case class Model(
    format: String,
    source: String
) extends ModelSerializer