package com.opendatagroup.fastscore.assets.builders

/** Stream object builder
  *
  * Example:
  * {{{
  *     val stream: Stream =
        new StreamBuilder()
            .withLoop(false)
            .withDescription("A file stream")
            .withNewFileTransport()
                .withPath("./input.jsons")
            .endTransport()
            .withEncoding(StreamEncoding.json)
                .withNewBatching()
                .withNagleTime(5)
                .endBatching()
            .endStream()
  * }}}
  *
  */

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.util._

/** Stream Transport Builder parent trait
  *
  */
sealed trait StreamTransportBuilder {
    def build(): StreamTransport
}

/** Stream Transport HTTP Builder
  *
  * @param _url Initial url value
  * @param retVal StreamBuilder value to return to
  */
class StreamTransportHTTPBuilder(_url: Option[String] = None)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var url: Option[String] = _url

    /** Set URL
      *
      * @param url
      * @return
      */
    def withURL(url: String): StreamTransportHTTPBuilder = {
        this.url = Some(url)
        this
    }

    /** End transport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.url.isDefined) retVal else {
            throw FastScoreError(s"Invalid Stream Transport: url not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportHTTP = {
        this.url match {
            case Some(url) => StreamTransportHTTP(url)
            case None => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}

/** Stream Transport Kafka builder
  *
  * @param _bootstrapServers Initial bootstrapServers value
  * @param _topic Initial topic value
  * @param _partition Initial partition value
  * @param _maxWaitTime Initial maxWaitTime value
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportKafkaBuilder(
    _bootstrapServers: Option[List[String]] = None,
    _topic: Option[String] = None,
    _partition: Option[Int] = Some(0),
    _maxWaitTime: Option[Int] = Some(0x7ffff)
)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var bootstrapServers: Option[List[String]] = _bootstrapServers
    private var topic: Option[String] = _topic
    private var partition: Option[Int] = _partition
    private var maxWaitTime: Option[Int] = _maxWaitTime

    /** Set bootStrapServers
      *
      * @param bootstrapServers
      * @return
      */
    def withBootStrapServers(bootstrapServers: List[String]): this.type = {
        this.bootstrapServers = Some(bootstrapServers)
        this
    }

    /** Set bootStrapServer
      *
      * @param bootstrapServer
      * @return
      */
    def withBootStrapServer(bootstrapServer: String): this.type = {
        if (this.bootstrapServers.isDefined)
            this.bootstrapServers = Some(bootstrapServer :: this.bootstrapServers.get)
        else
            this.bootstrapServers = Some(List(bootstrapServer))
        this
    }

    /** Set Topic
      *
      * @param topic
      * @return
      */
    def withTopic(topic: String): this.type = {
        this.topic = Some(topic)
        this
    }

    /** Set partition
      *
      * @param partition
      * @return
      */
    def withPartition(partition: Int): this.type = {
        this.partition = Some(partition)
        this
    }

    /** Set maxWaitTime
      *
      * @param maxWaitTime
      * @return
      */
    def withMaxWaitTime(maxWaitTime: Int): this.type = {
        this.maxWaitTime = Some(maxWaitTime)
        this
    }

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.bootstrapServers.isDefined && this.topic.isDefined) retVal else {
            var fields: List[String] = List()
            if (this.bootstrapServers.isEmpty) fields = "bootstrapServers" :: fields
            if (this.topic.isEmpty) fields = "topic" :: fields
            throw FastScoreError(s"Invalid Stream Transport: ${fields.mkString(",")} not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportKafka = {
        (this.bootstrapServers, this.topic) match {
            case (Some(bootstrapServers), Some(topic)) => StreamTransportKafka(bootstrapServers, topic, partition, maxWaitTime)
            case _ => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}

/** Stream Transport REST builder
  *
  * @param _mode Initial mode value
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportRESTBuilder(_mode: StreamTransportRESTMode.Value = StreamTransportRESTMode.simple)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var mode: StreamTransportRESTMode.Value = _mode

    /** Set Mode
      *
      * @param mode
      * @return
      */
    def withMode(mode: StreamTransportRESTMode.Value): this.type = {
        this.mode = mode
        this
    }

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = retVal

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportREST = StreamTransportREST(mode)
}

/** Stream Transport File builder
  *
  * @param _path Initial path value
  * @param retVal StreamTransport object to return to
  */
class StreamTransportFileBuilder(_path: Option[String] = None)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var path: Option[String] = _path

    /** Set Path
      *
      * @param path
      * @return
      */
    def withPath(path: String): this.type = {
        this.path = Some(path)
        this
    }

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.path.isDefined) retVal else {
            throw FastScoreError("Invalid Stream Transport: path not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportFile = {
        this.path match {
            case Some(path) => StreamTransportFile(path)
            case None => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}

/** Stream Transport ODBC builder
  *
  * @param _connectionString Initial connectionString value
  * @param _selectQuery Initial selectQuery value
  * @param _insertIntoTable Initial insertIntoTable value
  * @param _outputFields Initial outputFields value
  * @param _timeout Initial timeout value
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportODBCBuilder(
    _connectionString: Option[String] = None,
    _selectQuery: Option[String] = None,
    _insertIntoTable: Option[String] = None,
    _outputFields: Option[List[String]] = None,
    _timeout: Option[Int] = None
)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var connectionString: Option[String] = _connectionString
    private var selectQuery: Option[String] = _selectQuery
    private var insertIntoTable: Option[String] = _insertIntoTable
    private var outputFields: Option[List[String]] = _outputFields
    private var timeout: Option[Int] = _timeout

    /** Set connectionString
      *
      * @param connectionString
      * @return
      */
    def withConnectionString(connectionString: String): this.type = {
        this.connectionString = Some(connectionString)
        this
    }

    /** Set selectQuery
      *
      * @param selectQuery
      * @return
      */
    def withSelectQuery(selectQuery: String): this.type = {
        this.selectQuery = Some(selectQuery)
        this
    }

    /** Set insertIntoTable
      *
      * @param insertIntoTable
      * @return
      */
    def withInsertIntoTable(insertIntoTable: String): this.type = {
        this.insertIntoTable = Some(insertIntoTable)
        this
    }

    /** Set outputFields
      *
      * @param outputFields
      * @return
      */
    def withOutputFields(outputFields: List[String]): this.type = {
        this.outputFields = Some(outputFields)
        this
    }

    /** Set timeout
      *
      * @param timeout
      * @return
      */
    def withTimeout(timeout: Int): this.type = {
        this.timeout = Some(timeout)
        this
    }

    /** End StreamTransport specification
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.connectionString.isDefined && this.selectQuery.isDefined &&
            this.insertIntoTable.isDefined) retVal else {
                var fields: List[String] = List()
                if (this.connectionString.isEmpty) fields = "connectionString" :: fields
                if (this.selectQuery.isEmpty) fields = "selectQuery" :: fields
                if (this.insertIntoTable.isEmpty) fields = "insertIntoTable" :: fields
                throw FastScoreError(s"Invalid Stream Transport: ${fields.mkString(",")} not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportODBC = {
        (this.connectionString, this.selectQuery, this.insertIntoTable) match {
            case (Some(connectionString), Some(selectQuery), Some(insertIntoTable)) =>
                StreamTransportODBC(connectionString, selectQuery, insertIntoTable, outputFields, timeout)
            case _ => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}


/** Stream Transport TCP builder
  *
  * @param _host Initial host value
  * @param _port Initial port value
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportTCPBuilder(
    _host: Option[String] = None,
    _port: Option[Int] = None
)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var host: Option[String] = _host
    private var port: Option[Int] = _port

    /** Set host
      *
      * @param host
      * @return
      */
    def withHost(host: String): this.type = {
        this.host = Some(host)
        this
    }

    /** Set port
      *
      * @param port
      * @return
      */
    def withPort(port: Int): this.type = {
        this.port = Some(port)
        this
    }

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.host.isDefined && this.port.isDefined) retVal else {
            var fields: List[String] = List()
            if (this.host.isEmpty) fields = "host" :: fields
            if (this.port.isEmpty) fields = "port" :: fields
            throw FastScoreError(s"Invalid Stream Transport: ${fields.mkString(",")} not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportTCP = {
        (this.host, this.port) match {
            case (Some(host), Some(port)) => StreamTransportTCP(host, port)
            case _ => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}

/** Stream Transport UDP builder
  *
  * @param _bindTo Initial bindTo value
  * @param _port Initial port value
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportUDPBuilder(
    _bindTo: String = "0.0.0.0",
    _port: Option[Int] = None
)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var bindTo: String = _bindTo
    private var port: Option[Int] = _port

    /** Set bindTo
      *
      * @param bindTo
      * @return
      */
    def withBindTo(bindTo: String): this.type = {
        this.bindTo = bindTo
        this
    }

    /** Set port
      *
      * @param port
      * @return
      */
    def withPort(port: Int): this.type = {
        this.port = Some(port)
        this
    }

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.port.isDefined) retVal else {
            throw FastScoreError("Invalid Stream Transport: port not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportUDP = {
        this.port match {
            case Some(port) => StreamTransportUDP(bindTo, port)
            case None => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}

/** Stream Transport Exec builder
  *
  * @param _run Initial run value
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportExecBuilder(_run: Option[String] = None)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var run: Option[String] = None

    /** Set run
      *
      * @param run
      * @return
      */
    def withRun(run: String): this.type = {
        this.run = Some(run)
        this
    }

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.run.isDefined) retVal else {
            throw FastScoreError("Invalid Stream Transport: run not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportExec = {
        this.run match {
            case Some(run) => StreamTransportExec(run)
            case None => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}

/** Stream Transport Inline builder
  *
  * Only one of data or dataBinary may be defined
  *
  * @param _data Initial data value
  * @param _dataBinary Initial dataBinary value
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportInlineBuilder(
    _data: Option[Either[String, List[String]]] = None,
    _dataBinary: Option[Either[String, List[String]]] = None
)(retVal: StreamBuilder) extends StreamTransportBuilder {
    private var data: Option[Either[String, List[String]]] = _data
    private var dataBinary: Option[Either[String, List[String]]] = _dataBinary

    /** Set data (single)
      *
      * @param data
      * @return
      */
    def withData(data: String): this.type = {
        if (this.data.isDefined)
            this.data.get match {
                case Left(d) => this.data = Some(Right(List(d, data)))
                case Right(dl) => this.data = Some(Right(data :: dl))
            }
        else
            this.data = Some(Left(data))
        this
    }

    /** Set data (collection)
      *
      * @param data
      * @return
      */
    def withData(data: List[String]): this.type = {
        this.data = Some(Right(data))
        this
    }

    /** Set dataBinary (single)
      *
      * @param dataBinary
      * @return
      */
    def withDataBinary(dataBinary: String): this.type = {
        if (this.dataBinary.isDefined)
            this.dataBinary.get match {
                case Left(d) => this.dataBinary = Some(Right(List(d, dataBinary)))
                case Right(dl) => this.dataBinary = Some(Right(dataBinary :: dl))
            }
        else
            this.dataBinary = Some(Left(dataBinary))
        this
    }

    /** Set dataBinary (collection)
      *
      * @param dataBinary
      * @return
      */
    def withDataBinary(dataBinary: List[String]): this.type = {
        this.dataBinary = Some(Right(dataBinary))
        this
    }

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = {
        if (this.data.isDefined || this.dataBinary.isDefined) retVal else {
            throw FastScoreError("Invalid Stream Transport: data or dataBinary not defined")
        }
    }

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportInline = {
        (this.data, this.dataBinary) match {
            case (Some(data), None) => StreamTransportInline(this.data, this.dataBinary)
            case (None, Some(dataBinary)) => StreamTransportInline(this.data, this.dataBinary)
            case (Some(data), Some(dataBinary)) => StreamTransportInline(this.data, this.dataBinary)
            case _ => throw FastScoreError("Unable to build Stream Transport")
        }
    }
}

/** Stream Transport discard builder
  *
  * @param retVal StreamBuilder object to return to
  */
class StreamTransportDiscardBuilder()(retVal: StreamBuilder) extends StreamTransportBuilder {

    /** End StreamTransport spec
      *
      * @return StreamBuilder (retVal)
      */
    def endTransport(): StreamBuilder = retVal

    /** Build a StreamTransport object
      *
      * @return StreamTransport
      */
    def build(): StreamTransportDiscard.type = StreamTransportDiscard
}

/** Stream Envelope builder parent trait
  *
  */
sealed trait StreamEnvelopeBuilder {
    def build(): StreamEnvelope
}

/** Stream Envelope delimited builer
  *
  * @param _separator Initial separator value
  * @param retVal StreamBuilder object to return to
  */
class StreamEnvelopeDelimitedBuilder(_separator: String = "\n")(retVal: StreamBuilder) extends StreamEnvelopeBuilder {
    private var separator: String = _separator

    /** Set separator
      *
      * @param separator
      * @return
      */
    def withSeparator(separator: String): this.type = {
        this.separator = separator
        this
    }

    /** End StreamEnvelope spec
      *
      * @return StreamBuilder (retVal)
      */
    def endEnvelope(): StreamBuilder = retVal

    /** Build a StreamEnvelope object
      *
      * @return StreamEnvelope
      */
    override def build(): StreamEnvelopeDelimited = StreamEnvelopeDelimited(separator)
}

/** Stream Envelope Fixed builder
  *
  * @param _size Initial size value
  * @param retVal StreamBuilder object to return to
  */
class StreamEnvelopeFixedBuilder(_size: Option[Int] = None)(retVal: StreamBuilder) extends StreamEnvelopeBuilder {
    private var size: Option[Int] = _size

    /** Set size
      *
      * @param size
      * @return
      */
    def withSize(size: Int): this.type = {
        this.size = Some(size)
        this
    }

    /** End envelope spec
      *
      * @return StreamBuilder (retVal)
      */
    def endEnvelope(): StreamBuilder = {
        if (this.size.isDefined) retVal else {
            throw FastScoreError("Invalid Stream Envelope: size not defined")
        }
    }

    /** Build a StreamEnvelope object
      *
      * @return StreamEnvelope
      */
    override def build(): StreamEnvelopeFixed = {
        this.size match {
            case Some(size) => StreamEnvelopeFixed(size)
            case None => throw FastScoreError("Unable to build Stream Envelope")
        }
    }
}

/** Stream Envelope Ocf Block builder
  *
  * @param _syncMarker Initial syncMarker value
  * @param _skipHeader Initial skipHeader value
  * @param retVal StreamBuilder object to return to
  */
class StreamEnvelopeOcfBlockBuilder(
    _syncMarker: Option[String] = None,
    _skipHeader: Boolean = false
)(retVal: StreamBuilder) extends StreamEnvelopeBuilder {
    private var syncMarker: Option[String] = _syncMarker
    private var skipHeader: Boolean = _skipHeader

    /** Set syncMarker
      *
      * @param syncMarker
      * @return
      */
    def withSyncMarker(syncMarker: String): this.type = {
        this.syncMarker = Some(syncMarker)
        this
    }

    /** Set skipHeader
      *
      * @param skipHeader
      * @return
      */
    def withSkipHeader(skipHeader: Boolean): this.type = {
        this.skipHeader = skipHeader
        this
    }

    /** End StreamEnvelope spec
      *
      * @return StreamBuilder (retVal)
      */
    def endEnvelope(): StreamBuilder = {
        if (this.syncMarker.isDefined ||
          (this.syncMarker.isEmpty && !this.skipHeader)) retVal else {
            (this.syncMarker, this.skipHeader) match {
                case (None, true) =>
                    throw FastScoreError("Invalid Stream Envelope: if syncMarker is omitted, skipHeader must be false")
                case _ => throw FastScoreError("Invalid Stream Envelope")
            }
        }
    }

    /** Build a StreamEnvelope object
      *
      * @return StreamEnvelope
      */
    override def build(): StreamEnvelopeOcfBlock = {
        (this.syncMarker, this.skipHeader) match {
            case (Some(syncMarker), _) => StreamEnvelopeOcfBlock(this.syncMarker, this.skipHeader)
            case (None, false) => StreamEnvelopeOcfBlock(this.syncMarker, this.skipHeader)
            case _ => throw FastScoreError("Unable to build Stream Envelope")
        }
    }
}

/** Stream Batching builder
  *
  * @param _watermark Initial watermark value
  * @param _nagleTime Initial nagleTime value
  * @param retVal StreamBuilder object to return to
  */
class StreamBatchingBuilder(
    _watermark: Option[Int] = None,
    _nagleTime: Option[Int] = None
)(retVal: StreamBuilder) {
    private var watermark: Option[Int] = _watermark
    private var nagleTime: Option[Int] = _nagleTime

    /** Set watermark
      *
      * @param watermark
      * @return
      */
    def withWatermark(watermark: Int): this.type = {
        this.watermark = Some(watermark)
        this
    }

    /** Set nagleTime
      *
      * @param nagleTime
      * @return
      */
    def withNagleTime(nagleTime: Int): this.type = {
        this.nagleTime = Some(nagleTime)
        this
    }

    /** End StreamBatching spec
      *
      * @return StreamBuilder (retVal)
      */
    def endBatching(): StreamBuilder = {
        if (this.watermark.isDefined && this.nagleTime.isDefined) retVal else {
            var fields: List[String] = List()
            if (this.watermark.isEmpty) fields = "watermark" :: fields
            if (this.nagleTime.isEmpty) fields = "nagleTime" :: fields
            throw FastScoreError(s"Invalid Stream Batching: ${fields.mkString(",")} not defined")
        }
    }

    /** Build a StreamBatching object
      *
      * @return StreamBatching
      */
    def build(): StreamBatching = {
        (this.watermark, this.nagleTime) match {
            case (Some(watermark), Some(nagleTime)) => StreamBatching(watermark, nagleTime)
            case _ => throw FastScoreError("Unable to build Stream Batching")
        }
    }
}

/** Stream Schema Ref builder
  *
  * @param _ref Initial ref value
  * @param retVal StreamBuilder object to return to
  */
class StreamSchemaRefBuilder(_ref: Option[String] = None)(retVal: StreamBuilder) {
    private var ref: Option[String] = _ref

    /** Set ref
      *
      * @param ref
      * @return
      */
    def withRef(ref: String): this.type = {
        this.ref = Some(ref)
        this
    }

    /** End StreamSchemaRef spec
      *
      * @return StreamBuilder (retVal)
      */
    def endSchema(): StreamBuilder = {
        if (this.ref.isDefined) retVal else {
            throw FastScoreError("Invalid Stream Schema: ref not defined")
        }
    }

    /** Build a StreamSchemaRef object
      *
      * @return StreamSchemaRef
      */
    def build(): StreamSchemaRef = {
        this.ref match {
            case Some(ref) => StreamSchemaRef(ref)
            case None => throw FastScoreError("Unable to build Stream Schema")
        }
    }
}

/** Stream Builder
  *
  * @param _transportBuilder
  * @param _schemaBuilder
  * @param _batchingBuilder
  * @param _version
  * @param _description
  * @param _loop
  * @param _skipTo
  * @param _skipToRecord
  * @param _envelopeBuilder
  * @param _encoding
  * @param _lingerTime
  */
class StreamBuilder(
    _transportBuilder: Option[StreamBuilder => StreamTransportBuilder] = None,
    _schemaBuilder: Option[Either[String, StreamBuilder => StreamSchemaRefBuilder]] = None,
    _batchingBuilder: Option[Either[StreamBatchingMode.Value, StreamBuilder => StreamBatchingBuilder]] = None,
    _version: String = "1.2",
    _description: Option[String] = None,
    _loop: Boolean = false,
    _skipTo: Option[Int] = None,
    _skipToRecord: Option[Either[Int, KafkaSkipToRecord.Value]] = None,
    _envelopeBuilder: Option[StreamBuilder => StreamEnvelopeBuilder] = None,
    _encoding: Option[StreamEncoding.Value] = None,
    _lingerTime: Int = 3000
) {
    /** Required fields
      *
      */
    private var transportBuilder: Option[StreamTransportBuilder] = if (_transportBuilder.isDefined) Some(_transportBuilder.get(this)) else None
    private var schemaBuilder: Option[Either[String, StreamSchemaRefBuilder]] = _schemaBuilder match {
        case Some(Right(builder)) => Some(Right(builder(this)))
        case Some(Left(batchingMode)) => Some(Left(batchingMode))
        case None => None
    }
    private var batchingBuilder: Option[Either[StreamBatchingMode.Value, StreamBatchingBuilder]] = _batchingBuilder match {
        case Some(Right(builder)) => Some(Right(builder(this)))
        case Some(Left(batchingMode)) => Some(Left(batchingMode))
        case None => None
    }

    /** Optional fields
      *
      */
    private var version: String = _version
    private var description: Option[String] = _description
    private var loop: Boolean = _loop
    private var skipTo: Option[Int] = _skipTo
    private var skipToRecord: Option[Either[Int, KafkaSkipToRecord.Value]] = _skipToRecord
    private var envelopeBuilder: Option[StreamEnvelopeBuilder] = if (_envelopeBuilder.isDefined) Some(_envelopeBuilder.get(this)) else None
    private var encoding: Option[StreamEncoding.Value] = _encoding
    private var lingerTime: Int = _lingerTime

    /** Add a new HTTP Transport parameter
      *
      * @return
      */
    def withNewHTTPTransport(): StreamTransportHTTPBuilder = {
        val transportBuilder = new StreamTransportHTTPBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new Kafka Transport parameter
      *
      * @return
      */
    def withNewKafkaTransport(): StreamTransportKafkaBuilder = {
        val transportBuilder = new StreamTransportKafkaBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new REST Transport parameter
      *
      * @return
      */
    def withNewRESTTransport(): StreamTransportRESTBuilder = {
        val transportBuilder = new StreamTransportRESTBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new File Transport parameter
      *
      * @return
      */
    def withNewFileTransport(): StreamTransportFileBuilder = {
        val transportBuilder = new StreamTransportFileBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new ODBC Transport parameter
      *
      * @return
      */
    def withNewODBCTransportBuilder(): StreamTransportODBCBuilder = {
        val transportBuilder = new StreamTransportODBCBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new TCP Transport parameter
      *
      * @return
      */
    def withNewTCPTransportBuilder(): StreamTransportTCPBuilder = {
        val transportBuilder = new StreamTransportTCPBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new UDP Transport parameter
      *
      * @return
      */
    def withNewUDPTransport(): StreamTransportUDPBuilder = {
        val transportBuilder = new StreamTransportUDPBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new Exec Transport parameter
      *
      * @return
      */
    def withNewExecTransport(): StreamTransportExecBuilder = {
        val transportBuilder = new StreamTransportExecBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a new Inline Transport parameter
      *
      * @return
      */
    def withNewInlineTransport(): StreamTransportInlineBuilder = {
        val transportBuilder = new StreamTransportInlineBuilder()(this)
        this.transportBuilder = Some(transportBuilder)
        transportBuilder
    }

    /** Add a Discard Transport Parameter
      *
      * @return
      */
    def withTransportDiscard(): this.type = {
        this.transportBuilder = Some(new StreamTransportDiscardBuilder()(this))
        this
    }

    /** Set a Schema
      *
      * @param schema
      * @return
      */
    def withSchema(schema: String): this.type = {
        this.schemaBuilder = Some(Left(schema))
        this
    }

    /** Add a new Schema Ref parameter
      *
      * @return
      */
    def withNewSchemaRef(): StreamSchemaRefBuilder = {
        this.schemaBuilder = Some(Right(new StreamSchemaRefBuilder()(this)))
        this.schemaBuilder.get.right.get
    }

    /** Set Batching
      *
      * @param mode
      * @return
      */
    def withBatching(mode: StreamBatchingMode.Value): this.type = {
        this.batchingBuilder = Some(Left(mode))
        this
    }

    /** Add a new Batching parameter
      *
      * @return
      */
    def withNewBatching(): StreamBatchingBuilder = {
        this.batchingBuilder = Some(Right(new StreamBatchingBuilder()(this)))
        this.batchingBuilder.get.right.get
    }

    /** Set version
      *
      * @param version
      * @return
      */
    def withVersion(version: String): this.type = {
        this.version = version
        this
    }

    /** Set description
      *
      * @param description
      * @return
      */
    def withDescription(description: String): this.type = {
        this.description = Some(description)
        this
    }

    /** Set loop
      *
      * @param loop
      * @return
      */
    def withLoop(loop: Boolean): this.type = {
        this.loop = loop
        this
    }

    /** Set skipTo
      *
      * @param skipTo
      * @return
      */
    def withSkipTo(skipTo: Int): this.type = {
        this.skipTo = Some(skipTo)
        this
    }

    /** Set skipToRecord
      *
      * @param recordNumber
      * @return
      */
    def withSkipToRecord(recordNumber: Int): this.type = {
        this.skipToRecord = Some(Left(recordNumber))
        this
    }

    /** Set SkipToKafkaRecord
      *
      * @param record
      * @return
      */
    def withSkipToKafkaRecord(record: KafkaSkipToRecord.Value): this.type = {
        this.skipToRecord = Some(Right(record))
        this
    }

    /** Add a new Delimited Envelope parameter
      *
      * @return
      */
    def withNewDelimitedEnvelope(): StreamEnvelopeDelimitedBuilder = {
        val envelopeBuilder = new StreamEnvelopeDelimitedBuilder()(this)
        this.envelopeBuilder = Some(envelopeBuilder)
        envelopeBuilder
    }

    /** Add a new Fixed Envelope parameter
      *
      * @return
      */
    def withNewFixedEnvelope(): StreamEnvelopeFixedBuilder = {
        val envelopeBuilder = new StreamEnvelopeFixedBuilder()(this)
        this.envelopeBuilder = Some(envelopeBuilder)
        envelopeBuilder
    }

    /** Add a new Ocf Block Envelope parameter
      *
      * @return
      */
    def withNewOcfBlockEnvelope(): StreamEnvelopeOcfBlockBuilder = {
        val envelopeBuilder = new StreamEnvelopeOcfBlockBuilder()(this)
        this.envelopeBuilder = Some(envelopeBuilder)
        envelopeBuilder
    }

    /** Set encoding
      *
      * @param encoding
      * @return
      */
    def withEncoding(encoding: StreamEncoding.Value) = {
        this.encoding = Some(encoding)
        this
    }

    /** Set lingerTime
      *
      * @param lingerTime
      * @return
      */
    def withLingerTime(lingerTime: Int) = {
        this.lingerTime = lingerTime
        this
    }

    /** Build a Stream object
      *
      * @return
      */
    def endStream(): Stream = {
        (transportBuilder, batchingBuilder) match {
            case (Some(transportBuilder), Some(batchingBuilder)) =>
                    Stream(
                        version,
                        description,
                        transportBuilder.build(),
                        loop,
                        skipTo,
                        skipToRecord,
                        if (envelopeBuilder.isDefined) Some(envelopeBuilder.get.build()) else None,
                        encoding,
                        schemaBuilder match {
                            case Some(schema) => schema match {
                                case Right(schemaBuilder) => Some(Right(schemaBuilder.build()))
                                case Left(schema) => Some(Left(schema))
                            }
                            case None => None
                        },
                        batchingBuilder match {
                            case Right(batchingBuilder) => Right(batchingBuilder.build())
                            case Left(batching) => Left(batching)
                        },
                        lingerTime
                    )
            case _ =>
                var fields: List[String] = List()
                if (this.transportBuilder.isEmpty) fields = "transport" :: fields
                if (this.schemaBuilder.isEmpty) fields = "schema" :: fields
                if (this.batchingBuilder.isEmpty) fields = "batching" :: fields
                throw FastScoreError(s"Invalid Stream: ${fields.mkString(",")} not defined")
        }
    }
}