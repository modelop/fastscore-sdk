package com.opendatagroup.fastscore.experimental

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._

import scala.language.implicitConversions
import scala.language.postfixOps
//import scala.language.postfixOps

//val s = Stream.fromFile("stream.json")
//val s2 = Stream.fromFile("stream2.json")
//
//implicit val proxy = new Proxy("kdmag")
//val engine = new Engine("engine-1")
//
//s |> engine |> s2
// s |> engine slot 2
// engine slot 3 |> s

object Pipeline {
  implicit def streamToPipeLHS(s: Stream): PipeLHS = new PipeLHS(stream = Some(s))
  implicit def engineToPipeLHS(e: Engine): PipeLHS = new PipeLHS(engine = Some(e))

  //def slot(input: Int)(e: Engine): (Int, Engine) = (input, e)
  def slot(input: Int, e: Engine): (Int, Engine) = (input, e)

  implicit def intToIntDupe(a: Int): PipeRHS.type = PipeRHS(a)
  implicit def engineToIntDupe(e: Engine): PipeRHS.type = PipeRHS(e)

  def test(): Unit = {
    implicit val proxy = new Proxy("https://127.0.0.1:8000")
    val engine1 = new Engine("engine-1")
    val engine2 = new Engine("engine-1")
    val engine3 = new Engine("engine-1")

    val s1 = Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-in.json")
    val s2 = Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-out.json")
    val s3 = Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-out.json")
    val s4 = Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-in.json")
    val s5 = Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-out.json")
    val s6 = Stream.fromFile("/Users/george/Documents/Work/fastscore-integration-tests/models/file-out.json")

    engine1.attachStream(0, s1)

    // Model compare
    s1 |> engine1 |> s2 |> (0) (engine2)
     /* truth --> */ s3 |> (2) (engine2) (1) |> s2
                     s3 |> (engine2) (3) |> s4
  }

  object PipeRHS {
    var inSlotNo: Option[Int] = None
    var engine: Option[Engine] = None
    var outSlotNo: Option[Int] = None

    def apply(a: Int): this.type = {
      engine match {
        case Some(_) => outSlotNo = Some(a)
        case None => inSlotNo = Some(a)
      }
      this
    }

    def apply(e: Engine): this.type = {
      engine = Some(e)
      this
    }
  }

  implicit def pipeRHStoPipeLHS(a: PipeRHS.type): PipeLHS = {
    val lhs = new PipeLHS(engine = a.engine)
    if (a.inSlotNo.isDefined)
      lhs.inputSlotNo = a.inSlotNo.get
    if (a.outSlotNo.isDefined)
      lhs.outputSlotNo = a.outSlotNo.get
    lhs
  }

  class PipeLHS(
      val stream: Option[Stream] = None,
      val engine: Option[Engine] = None,
      val _inputSlotNo: Int = 0,
      val _outputSlotNo: Int = 1
  ) {

    var inputSlotNo = _inputSlotNo
    var outputSlotNo = _outputSlotNo


    def |>(a: PipeRHS.type): PipeLHS = {
      if (a.inSlotNo.isDefined)
        this.inputSlotNo = a.inSlotNo.get
      if (a.outSlotNo.isDefined)
        this.outputSlotNo = a.outSlotNo.get
      this.|>(a.engine.get)
    }

    def |>(s: Stream): PipeLHS = {
      engine match {
        case Some(e) =>
          e.attachStream(outputSlotNo, s)
          new PipeLHS(stream = Some(s), _inputSlotNo = inputSlotNo, _outputSlotNo = outputSlotNo)
        case None => throw FastScoreError("The LHS operator for [ |> Stream ] must be an engine")
      }
    }

    def |>(e: Engine): PipeLHS = {
      stream match {
        case Some(s) =>
          e.attachStream(inputSlotNo, s)
          new PipeLHS(engine = Some(e), _inputSlotNo = inputSlotNo, _outputSlotNo = outputSlotNo)
        case None => throw FastScoreError("The LHS operator for [ |> Engine ] must be a stream")
      }
    }
  }
}