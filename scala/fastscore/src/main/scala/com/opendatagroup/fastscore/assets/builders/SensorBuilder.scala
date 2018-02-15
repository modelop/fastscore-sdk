package com.opendatagroup.fastscore.assets.builders

/** Sensor object builder
  *
  * Example: {{{
  *         val sensor: Sensor =
        new SensorBuilder()
            .withDescription("input record count")
            .withNewActivate()
                .withDuration(3.0)
                .withMaxReads(100)
            .endActivate()
            .withNewReport()
                .withInterval(5.0)
            .endReport()
            .endSensor()
  * }}}
  *
  */

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.util._

/** Sensor Tap parameter builder
  *
  * @param _prefix Initial prefix value
  * @param _suffix Initial suffix value
  * @param retVal SensorBuilder object to return to
  */
class SensorTapBuilder(
    _prefix: Option[SensorTapPrefix.Value] = None,
    _suffix: Option[SensorTapSuffix.Value] = None
)(retVal: SensorBuilder) {
    private var prefix: Option[SensorTapPrefix.Value] = _prefix
    private var suffix: Option[SensorTapSuffix.Value] = _suffix

    /** Set Prefix
      *
      * @param prefix
      * @return
      */
    def withPrefix(prefix: SensorTapPrefix.Value): this.type = {
        this.prefix = Some(prefix)
        this
    }

    /** Set Suffix
      *
      * @param suffix
      * @return
      */
    def withSuffix(suffix: SensorTapSuffix.Value): this.type = {
        this.suffix = Some(suffix)
        this
    }

    /** End tap parameter spec
      *
      * Used to chain builders
      *
      * @return SensorBuilder (retVal)
      */
    def endTap(): SensorBuilder = {
        if (this.prefix.isDefined && this.suffix.isDefined) retVal else {
            var fields: List[String] = List()
            if (this.prefix.isEmpty) fields = "prefix" :: fields
            if (this.suffix.isEmpty) fields = "suffix" :: fields
            throw FastScoreError(s"Invalid Sensor Tap: ${fields.mkString(",")} not defined")
        }
    }

    /** Build a SensorTap object
      *
      * @return SensorTap
      */
    def build(): SensorTap = {
        (prefix, suffix) match {
            case (Some(prefix), Some(suffix)) => SensorTap(prefix, suffix)
            case _ => throw FastScoreError("Unable to build Sensor Tap")
        }
    }
}

/** Sensor Activate parameter builder
  *
  * @param __type initial type
  * @param _intensityOrInterval initial intensity or interval
  * @param _duration initial duration
  * @param _maxReads initial maxReads
  * @param retVal SensorBuilder object to return to
  */
class SensorActivateBuilder(
    __type: Option[SensorActivateType.Value] = None,
    _intensityOrInterval: Option[SensorActivateIntensityOrInterval] = None,
    _duration: Option[Double] = None,
    _maxReads: Option[Int] = Some(1)
)(retVal: SensorBuilder) {
    /** Required
      *
      */
    private var _type: Option[SensorActivateType.Value] = __type
    /** Optional
      *
      */
    private var intensityOrInterval: Option[SensorActivateIntensityOrInterval] = _intensityOrInterval
    private var duration: Option[Double] = _duration
    private var maxReads: Option[Int] = _maxReads

    /** Set type
      *
      * @param _type
      * @return
      */
    def withType(_type: SensorActivateType.Value): this.type = {
        this._type = Some(_type)
        this
    }

    /** Set intensity
      *
      * @param intensity
      * @return
      */
    def withIntensity(intensity: SensorActivateIntensity): this.type = {
        this.intensityOrInterval = Some(intensity)
        this
    }

    /** Set interval
      *
      * @param interval
      * @return
      */
    def withInterval(interval: SensorActivateInterval): this.type = {
        this.intensityOrInterval = Some(interval)
        this
    }

    /** Set duration
      *
      * @param duration
      * @return
      */
    def withDuration(duration: Double): this.type = {
        this.duration = Some(duration)
        this
    }

    /** Set MaxReads
      *
      * @param maxReads
      * @return
      */
    def withMaxReads(maxReads: Int): this.type = {
        this.maxReads = Some(maxReads)
        this
    }

    /** End Activate parameter spec
      *
      * Used to chain builders
      *
      * @return SensorBuilder (retVal)
      */
    def endActivate(): SensorBuilder = {
        if (this._type.isDefined) retVal else {
            throw FastScoreError(s"Invalid Sensor Activate: type not defined")
        }
    }

    /** Build a SensorActivate object
      *
      * @return SensorActivate
      */
    def build(): SensorActivate = {
        _type match {
            case Some(_type) => SensorActivate(_type, intensityOrInterval, duration, maxReads)
            case _ => throw FastScoreError("Unable to build Sensor Activate")
        }
    }
}

/** Sensor Filter parameter builder
  *
  * @param __type initial type
  * @param _threshold initial threshold
  * @param _minValue initial minValue
  * @param _maxValue initial maxValue
  * @param retVal SensorBuilder object to return to
  */
class SensorFilterBuilder(
    __type: Option[SensorFilterType.Value] = None,
    _threshold: Option[Either[Int, Double]] = None,
    _minValue: Option[Either[Int, Double]] = None,
    _maxValue: Option[Either[Int, Double]] = None
)(retVal: SensorBuilder) {
    /** Required
      *
      */
    private var _type: Option[SensorFilterType.Value] = __type
    private var threshold: Option[Either[Int, Double]] = _threshold
    /** Optional
      *
      */
    private var minValue: Option[Either[Int, Double]] = _minValue
    private var maxValue: Option[Either[Int, Double]] = _maxValue

    /** Set type
      *
      * @param _type
      * @return
      */
    def withType(_type: SensorFilterType.Value): this.type = {
        this._type = Some(_type)
        this
    }

    /** Set Integer threshold
      *
      * @param threshold
      * @return
      */
    def withThreshold(threshold: Int): this.type = {
        this.threshold = Some(Left(threshold))
        this
    }

    /** Set Double threshold
      *
      * @param threshold
      * @return
      */
    def withThreshold(threshold: Double): this.type = {
        this.threshold = Some(Right(threshold))
        this
    }

    /** Set Integer MinValue
      *
      * @param minValue
      * @return
      */
    def withMinValue(minValue: Int): this.type = {
        this.minValue = Some(Left(minValue))
        this
    }

    /** Set Double MinValue
      *
      * @param minValue
      * @return
      */
    def withMinValue(minValue: Double): this.type = {
        this.minValue = Some(Right(minValue))
        this
    }

    /** Set Integer MaxValue
      *
      * @param maxValue
      * @return
      */
    def withMaxValue(maxValue: Int): this.type = {
        this.maxValue = Some(Left(maxValue))
        this
    }

    /** Set Double MaxValue
      *
      * @param maxValue
      * @return
      */
    def withMaxValue(maxValue: Double): this.type = {
        this.maxValue = Some(Right(maxValue))
        this
    }

    /** End Filter spec
      *
      * Used to chain builders
      *
      * @return SensorBuilder (retVal)
      */
    def endFilter(): SensorBuilder = {
        if (this._type.isDefined && this.threshold.isDefined) retVal else {
            var fields: List[String] = List()
            if (this._type.isEmpty) fields = "Type" :: fields
            if (this.threshold.isEmpty) fields = "Threshold" :: fields
            throw FastScoreError(s"Invalid Sensor Filter: ${fields.mkString(",")} not defined")
        }
    }

    /** Build a SensorFilter object
      *
      * @return SensorFilter
      */
    def build(): SensorFilter = {
        (_type, threshold) match {
            case (Some(_type), Some(threshold)) => SensorFilter(_type, threshold, minValue, maxValue)
            case _ => throw FastScoreError("Unable to build Sensor Filter")
        }
    }
}

/** Sensor Aggregate parameter builder
  *
  * @param __type initial type
  * @param _sampleSize initial sampleSize
  * @param retVal SensorBuilder object to return to
  */
class SensorAggregateBuilder(
    __type: SensorAggregateType.Value = SensorAggregateType.accumulate,
    _sampleSize: Option[Int] = None
)(retVal: SensorBuilder) {
    private var _type: SensorAggregateType.Value = __type
    private var sampleSize: Option[Int] = _sampleSize

    /** Set Type
      *
      * @param _type
      * @return
      */
    def withType(_type: SensorAggregateType.Value): this.type = {
        this._type = _type
        this
    }

    /** Set SampleSize
      *
      * @param sampleSize
      * @return
      */
    def withSampleSize(sampleSize: Int): this.type = {
        this.sampleSize = Some(sampleSize)
        this
    }

    /** End Aggregate spec
      *
      * Used to chain builders
      *
      * @return SensorBuilder (retVal)
      */
    def endAggregate(): SensorBuilder = retVal

    /** Build a SensorAggregate object
      *
      * @return SensorAggregate
      */
    def build(): SensorAggregate = SensorAggregate(_type, sampleSize)
}

/** Sensor Sink parameter builder
  *
  * @param _sinkType initial sinkType
  * @param _topic initial topic
  * @param _partition inital partition
  * @param retVal SensorBuilder object to return to
  */
class SensorSinkBuilder(
    _sinkType: SensorSinkType.Value = SensorSinkType.pneumo,
    _topic: Option[String] = None,
    _partition: Option[Int] = Some(0)
)(retVal: SensorBuilder) {
    /** Required
      *
      */
    private var sinkType: SensorSinkType.Value = _sinkType
    private var topic: Option[String] = _topic
    /** Optional
      *
      */
    private var partition: Option[Int] = _partition

    /** Set Type
      *
      * @param sinkType
      * @return
      */
    def withType(sinkType: SensorSinkType.Value): this.type = {
        this.sinkType= sinkType
        this
    }

    /** Set topic
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

    /** End sink spec
      *
      * Used to chain builders
      *
      * @return SensorBuilder (retVal)
      */
    def endSink(): SensorBuilder = sinkType match {
        case SensorSinkType.pneumo => retVal
        case SensorSinkType.kafka =>
            if (this.topic.isDefined) retVal else throw FastScoreError("Invalid Sensor Sink: topic not defined")
    }

    /** Build a SensorSink object
      *
      * @return SensorSink
      */
    def build(): SensorSink = sinkType match {
        case SensorSinkType.pneumo => SensorSinkPneumo
        case SensorSinkType.kafka =>
            if (this.topic.isDefined) SensorSinkKafka(topic.get, partition) else throw FastScoreError("Unable to build Sensor Sink")
    }

}

/** Sensor Report parameter builder
  *
  * @param _interval initial interval
  * @param retVal SensorBuilder object to return to
  */
class SensorReportBuilder(_interval: Double = 0.0)(retVal: SensorBuilder) {
    private var interval: Double = _interval

    /** Set interval
      *
      * @param interval
      * @return
      */
    def withInterval(interval: Double): this.type = {
        this.interval = interval
        this
    }

    /** End report spec
      *
      * Used to chain builders
      *
      * @return SensorBuilder (retVal)
      */
    def endReport(): SensorBuilder = retVal

    /** Build a SensorReport object
      *
      * @return SensorReport
      */
    def build(): SensorReport = SensorReport(interval)
}

/** SensorBuilder
  *
  * @param _tapBuilder
  * @param _activateBuilder
  * @param _sinkBuilder
  * @param _description
  * @param _filterBuilder
  * @param _aggregateBuilder
  * @param _reportBuilder
  */
class SensorBuilder(
    _tapBuilder: Option[SensorBuilder => SensorTapBuilder] = None,
    _activateBuilder: Option[SensorBuilder => SensorActivateBuilder] = None,
    _sinkBuilder: Option[SensorBuilder => SensorSinkBuilder] = None,
    _description: Option[String] = None,
    _filterBuilder: Option[SensorBuilder => SensorFilterBuilder] = None,
    _aggregateBuilder: Option[SensorBuilder => SensorAggregateBuilder] = None,
    _reportBuilder: Option[SensorBuilder => SensorReportBuilder] = None
) {
    /** Required builders
      *
      */
    private var tapBuilder: Option[SensorTapBuilder] = if (_tapBuilder.isDefined) Some(_tapBuilder.get(this)) else None
    private var activateBuilder: Option[SensorActivateBuilder] = if (_activateBuilder.isDefined) Some(_activateBuilder.get(this)) else None
    private var sinkBuilder: Option[SensorSinkBuilder] = if (_sinkBuilder.isDefined) Some(_sinkBuilder.get(this)) else None
    /** Optional builders
      *
      */
    private var description: Option[String] = _description
    private var filterBuilder: Option[SensorFilterBuilder] = if (_filterBuilder.isDefined) Some(_filterBuilder.get(this)) else None
    private var aggregateBuilder: Option[SensorAggregateBuilder] = if (_aggregateBuilder.isDefined) Some(_aggregateBuilder.get(this)) else None
    private var reportBuilder: Option[SensorReportBuilder] = if (_reportBuilder.isDefined) Some(_reportBuilder.get(this)) else None

    /** Add a new Tap parameter
      *
      * @return SensorTapBuilder
      */
    def withNewTap(): SensorTapBuilder = {
        this.tapBuilder = Some(new SensorTapBuilder()(this))
        this.tapBuilder.get
    }

    /** Add a new Activate parameter
      *
      * @return SensorActivateBuilder
      */
    def withNewActivate(): SensorActivateBuilder = {
        this.activateBuilder = Some(new SensorActivateBuilder()(this))
        this.activateBuilder.get
    }

    /** Add a new Sink parameter
      *
      * @return SensorSinkBuilder
      */
    def withNewSink(): SensorSinkBuilder = {
        this.sinkBuilder = Some(new SensorSinkBuilder()(this))
        this.sinkBuilder.get
    }

    /** Add a description
      *
      * @param description
      * @return SensorBuilder
      */
    def withDescription(description: String): SensorBuilder = {
        this.description = Some(description)
        this
    }

    /** Add a new Filter parameter
      *
      * @return SensorFilterBuilder
      */
    def withNewFilter(): SensorFilterBuilder = {
        this.filterBuilder = Some(new SensorFilterBuilder()(this))
        this.filterBuilder.get
    }

    /** Add a new Aggregate parameter
      *
      * @return SensorAggregateBuilder
      */
    def withNewAggregate(): SensorAggregateBuilder = {
        this.aggregateBuilder = Some(new SensorAggregateBuilder()(this))
        this.aggregateBuilder.get
    }

    /** Add a new Report parameter
      *
      * @return SensorReportBuilder
      */
    def withNewReport(): SensorReportBuilder = {
        this.reportBuilder = Some(new SensorReportBuilder()(this))
        this.reportBuilder.get
    }

    /** Build a sensor object
      *
      * @return Sensor
      */
    def endSensor(): Sensor = {
        (tapBuilder, activateBuilder, sinkBuilder) match {
            case (Some(tapBuilder), Some(activateBuilder), Some(sinkBuilder)) =>
                Sensor(
                    tapBuilder.build,
                    description,
                    activateBuilder.build,
                    if (filterBuilder.isDefined) Some(filterBuilder.get.build) else None,
                    if (aggregateBuilder.isDefined) Some(aggregateBuilder.get.build) else None,
                    sinkBuilder.build,
                    if (reportBuilder.isDefined) Some(reportBuilder.get.build) else None
                )
            case _ =>
                var fields: List[String] = List()
                if (this.tapBuilder.isEmpty) fields = "tap" :: fields
                if (this.activateBuilder.isEmpty) fields = "activate" :: fields
                if (this.sinkBuilder.isEmpty) fields = "sink" :: fields
                throw FastScoreError(s"Invalid Sensor: ${fields.mkString(",")} not defined")
        }
    }
}