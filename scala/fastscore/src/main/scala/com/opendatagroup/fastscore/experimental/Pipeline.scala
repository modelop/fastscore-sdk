package com.opendatagroup.fastscore.experimental

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.assets.builders.StreamBuilder
import com.opendatagroup.fastscore.fleet._
import com.opendatagroup.fastscore.util._
import com.opendatagroup.fastscore.assets.Constants.{DEFAULT_INPUT_SLOTNO, DEFAULT_OUTPUT_SLOTNO}
import com.opendatagroup.fastscore.experimental.Pipeline.{EnginePipeLHS, EnginePipeRHS}
import com.opendatagroup.fastscore.experimental.Pool.{EnginePipeLHSPooled, EnginePool, StreamPool}

import scala.language.implicitConversions
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

object Pool {

  case class EnginePool(c: Connect)

  object PipelineContext {
    private var ep: Option[EnginePool] = None
    private var sp: Option[StreamPool] = None

    def withEnginePool(pool: EnginePool): this.type = {
      this.ep = Some(pool)
      this
    }

    def withStreamPool(pool: StreamPool): this.type = {
      this.sp = Some(pool)
      this
    }

    def apply(v: => Unit):Unit = {
      val enginePool = ep match {
        case Some(ep) => ep
        case None => throw FastScoreError("Engine Pool undefined")
      }
      val streamPool = sp match {
        case Some(sp) => sp
        case None => throw FastScoreError("Stream Pool undefined")
      }
      Pipeline(enginePool)(streamPool)
      v
    }
  }

  class KafkaStreamPool(
      bootStrapServer: String,
      baseName: String = "topic"
  ) {
    implicit val kafkaStreamPool = new StreamPool(
      (schemaRef: String, index: Int) => {
        Some(
          new StreamBuilder()
              .withLoop(false)
              .withNewKafkaTransport()
              .withBootStrapServer(bootStrapServer)
              .withTopic(s"$baseName$index")
              .endTransport()
              .withNewSchemaRef()
              .withRef(schemaRef)
              .endSchema()
              .withBatching(StreamBatchingMode.normal)
              .withEncoding(StreamEncoding.json)
              .endStream())
      })
  }


  class StreamPool(nextStream: (String, Int) => Option[Stream]) {
    private var count = 0

    def next(schemaRef: String, index: Int = count): Stream = nextStream(schemaRef, index) match {
      case Some(s) =>
        count += 1
        s
      case None => throw FastScoreError("Stream Pool is empty")
    }
  }
  /*
  <pooled-engine> |> <engine>
  <pooled-engine> |> <pooled-engine>
  <pooled-engine> |> <generated-stream> |> <pooled-engine>
   */

  object EnginePipeRHS {
    var engineOpt: Option[Engine] = None
    var inputSlotNo: Int = DEFAULT_INPUT_SLOTNO
    var outputSlotNo: Int = DEFAULT_OUTPUT_SLOTNO

    def apply(e: Engine): this.type = {
      this.engineOpt = Some(e)
      this
    }
    def apply(slotNo: Int): this.type = {
      // Engine is the 'pivot'
      this.engineOpt match {
        case Some(_) => this.outputSlotNo = slotNo
        case None => this.inputSlotNo = slotNo
      }
      this
    }
  }

  implicit def enginePipeRHStoPooled(lhs: EnginePipeRHS)(implicit streamPool: StreamPool): EnginePipeLHSPooled = new EnginePipeLHSPooled(lhs.engine, lhs.inputSlotNo, lhs.outputSlotNo)

  class EnginePipeLHSPooled(
      override val engine: Engine,
      override val inputSlotNo: Int,
      override val outputSlotNo: Int
  )(implicit val streamPool: StreamPool) extends EnginePipeLHS(engine, inputSlotNo, outputSlotNo) {

//    // A crutch because Scala doesn't do 'two-step' implicits
//    def |>(rhsObj: EnginePipeRHS.type): EnginePipeLHS = {
//      this.|>(rhsObj.asInstanceOf[EnginePipeRHS])
//    }

    def |>(rhs: EnginePipeRHS): EnginePipeLHSPooled = {
      val outputSchema = engine.model match {
        case Some(model) => model.schema.get(outputSlotNo) match {
          case Some(schema) => schema
          case None => throw FastScoreError(s"Unable to infer output schema: schema for slot $outputSlotNo not defined")
        }
        case None => throw FastScoreError("Unable to infer output schema: model not set")
      }
      val stream = streamPool.next(outputSchema)
      this.|>(stream).|>(rhs).asInstanceOf[EnginePipeLHSPooled]
    }
  }
}

object Pipeline {
  private var ep: Option[EnginePool] = None
  private var sp: Option[StreamPool] = None

  def apply(ep: EnginePool): this.type = {
    this.ep = Some(ep)
    this
  }

  def apply(sp: StreamPool): this.type = {
    this.sp = Some(sp)
    this
  }

  def pnt(): Unit = {
    println(ep.get)
  }

  trait PipeLHS {
  }

  trait PipeRHS {
    val inputSlotNo: Int
    val outputSlotNo: Int
  }

  // Engine
  implicit def intToEngineRHS(slotNo: Int): EnginePipeRHS.type = EnginePipeRHS(slotNo)
  implicit def engineToEngineRHSObj(engine: Engine): EnginePipeRHS.type = EnginePipeRHS(engine)
  implicit def engineRHSObjToRHS(obj: EnginePipeRHS.type): EnginePipeRHS = {
    obj.engineOpt match {
      case Some(engine) => {
        val rhs = new EnginePipeRHS(engine, obj.inputSlotNo, obj.outputSlotNo)
        obj.engineOpt = None
        obj.inputSlotNo = DEFAULT_INPUT_SLOTNO
        obj.outputSlotNo = DEFAULT_OUTPUT_SLOTNO
        rhs
      }
      case None => throw FastScoreError("Unable to instantiate Pipeline RHS: Engine not defined")
    }
  }
  implicit def engineRHSObjToLHS(obj: EnginePipeRHS.type): EnginePipeLHS = {
    obj.engineOpt match {
      case Some(engine) => {
        val rhs = new EnginePipeLHS(engine, obj.inputSlotNo, obj.outputSlotNo)
        obj.engineOpt = None
        obj.inputSlotNo = DEFAULT_INPUT_SLOTNO
        obj.outputSlotNo = DEFAULT_OUTPUT_SLOTNO
        rhs
      }
      case None => throw FastScoreError("Unable to instantiate Pipeline LHS: Engine not defined")
    }
  }
  implicit def engineRHStoRHSObj(rhs: EnginePipeRHS): EnginePipeRHS.type = EnginePipeRHS(rhs.inputSlotNo)(rhs.engine)(rhs.outputSlotNo)

  // Stream
  implicit def streamToStreamLHS(stream: Stream): StreamPipeLHS = new StreamPipeLHS(stream)
  implicit def streamToStreamRHS(stream: Stream): StreamPipeRHS = new StreamPipeRHS(stream)
  implicit def streamRHSToStreamLHS(rhs: StreamPipeRHS): StreamPipeLHS = new StreamPipeLHS(rhs.stream)

  class EnginePipeRHS(
      val engine: Engine,
      val inputSlotNo: Int,
      val outputSlotNo: Int
  ) extends PipeRHS {
  }

  object EnginePipeRHS {
    var engineOpt: Option[Engine] = None
    var inputSlotNo: Int = DEFAULT_INPUT_SLOTNO
    var outputSlotNo: Int = DEFAULT_OUTPUT_SLOTNO

    def apply(e: Engine): this.type = {
      this.engineOpt = Some(e)
      this
    }
    def apply(slotNo: Int): this.type = {
      // Engine is the 'pivot'
      this.engineOpt match {
        case Some(_) => this.outputSlotNo = slotNo
        case None => this.inputSlotNo = slotNo
      }
      this
    }
  }


  // Trick for optional implicit parameters
  // Source: http://missingfaktor.blogspot.com/2013/12/optional-implicit-trick-in-scala.html
  case class Perhaps[E](value: Option[E]) {
    def fold[F](ifAbsent: => F)(ifPresent: E => F): F = {
      value.fold(ifAbsent)(ifPresent)
    }
  }
  implicit def perhaps[E](implicit ev: E = null): Perhaps[E] = Perhaps(Option(ev))

  class EnginePipeLHS(
      val engine: Engine,
      val inputSlotNo: Int,
      val outputSlotNo: Int
  ) extends PipeLHS {

    def |>(rhs: EnginePipeRHS.type)(implicit toPooledOpt: Perhaps[EnginePipeRHS => EnginePipeLHSPooled]): EnginePipeLHSPooled = {
      toPooledOpt.fold[EnginePipeLHSPooled] {
        throw FastScoreError("No implicit conversion available for <engine> |> <engine>; use <engine> |> <stream> |> <engine> or use Pools")
      } { implicit toPooled =>
          val pool = toPooled(new EnginePipeRHS(rhs.engineOpt.get, rhs.inputSlotNo, rhs.outputSlotNo))
          rhs.engineOpt = None
          rhs.inputSlotNo = DEFAULT_INPUT_SLOTNO
          rhs.outputSlotNo = DEFAULT_OUTPUT_SLOTNO
          pool
      }
    }

    def |>(rhs: StreamPipeRHS): StreamPipeLHS = {
      engine.attachStream(outputSlotNo, rhs.stream)
      streamRHSToStreamLHS(rhs)
    }
  }

  class StreamPipeRHS(
      val stream: Stream
  ) extends PipeLHS {
  }

  class StreamPipeLHS(
      val stream: Stream
  ) extends PipeLHS {

    // A crutch because Scala doesn't do 'two-step' implicits
    def |>(rhsObj: EnginePipeRHS.type): EnginePipeLHS = {
      this.|>(engineRHSObjToRHS(rhsObj))
    }

    def |>(rhs: EnginePipeRHS): EnginePipeLHS = {
      rhs.engine.attachStream(rhs.inputSlotNo, stream)
      engineRHSObjToLHS(engineRHStoRHSObj(rhs))
    }
  }

//  class PipeLHS(
//      var stream: Option[Stream] = None,
//      var engine: Option[Engine] = None,
//      val _inputSlotNo: Int = 0,
//      val _outputSlotNo: Int = 1
//  )(implicit val streamPool: StreamPool) {
//
//    var inputSlotNo = _inputSlotNo
//    var outputSlotNo = _outputSlotNo
//
//    var prevEngine: Option[Engine] = None
//
//
//    def |>(a: PipeRHS.type): PipeLHS = {
//      if (a.inSlotNo.isDefined)
//        this.inputSlotNo = a.inSlotNo.get
//      if (a.outSlotNo.isDefined)
//        this.outputSlotNo = a.outSlotNo.get
//      this.|>(a.engine.get)
//    }
//
//    def |>(s: Stream): PipeLHS = {
//      engine match {
//        case Some(e) =>
//          e.attachStream(outputSlotNo, s)
//          prevEngine match {
//            case Some(prevEngine) =>
//              this.prevEngine = None
//              this.stream = Some(s)
//              this.engine = None
//              this.|>(prevEngine)
//            case None =>
//              new PipeLHS(stream = Some(s), _inputSlotNo = inputSlotNo, _outputSlotNo = outputSlotNo)
//          }
//        case None => throw FastScoreError("The LHS operator for [ |> Stream ] must be an engine")
//      }
//    }
//
//    def injectStream(engine: Engine)(implicit streamPool: StreamPool): PipeLHS = {
//      this.engine.get.model.get.schema.get(this.outputSlotNo) match {
//        case Some(oldSlot) =>
//          val stream = streamPool.next(oldSlot)
//          this.prevEngine = Some(engine)
//          this.|>(stream)
//        case None => throw FastScoreError("Schema for output slot not defined")
//      }
//    }

    // 1. Generate stream
    // 2. Call |>(stream) with engine reset back to engine1 and prevengine set to engine2
    // 3. In |>, if prevengine is defined, call |>(prevengine)

//    engine1 |> engine2
//    implicit def engineToPipeLHS(e: Engine)(implicit streamPool: StreamPool): PipeLHS = new PipeLHS(engine = Some(e))
//
//    def |>(e: Engine): PipeLHS = {
//      (stream, engine) match {
//        case (Some(s), None) =>
//          e.attachStream(inputSlotNo, s)
//          new PipeLHS(engine = Some(e), _inputSlotNo = inputSlotNo, _outputSlotNo = outputSlotNo)
//        case (None, Some(engine)) =>
//          this.injectStream(e)
//        case _ =>throw FastScoreError("The LHS operator for [ |> Engine ] must be a stream")
//      }
//    }
//  }
}