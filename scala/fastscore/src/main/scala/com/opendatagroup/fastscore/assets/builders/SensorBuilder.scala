package com.opendatagroup.fastscore.assets.builders

import com.opendatagroup.fastscore.assets._
import com.opendatagroup.fastscore.util._

class SensorTapBuilder(
    _prefix: Option[SensorTapPrefix.Value] = None,
    _suffix: Option[SensorTapSuffix.Value] = None
)(retVal: SensorBuilder) {
    private var prefix: Option[SensorTapPrefix.Value] = _prefix
    private var suffix: Option[SensorTapSuffix.Value] = _suffix

    def withPrefix(prefix: SensorTapPrefix.Value): this.type = {
        this.prefix = Some(prefix)
        this
    }
    def withSuffix(suffix: SensorTapSuffix.Value): this.type = {
        this.suffix = Some(suffix)
        this
    }
    def endTap(): SensorBuilder = {
        if (this.prefix.isDefined && this.suffix.isDefined) retVal else {
            var fields: List[String] = List()
            if (this.prefix.isEmpty) fields = "prefix" :: fields
            if (this.suffix.isEmpty) fields = "suffix" :: fields
            throw FastScoreError(s"Invalid Sensor Tap: ${fields.mkString(",")} not defined")
        }
    }
    def build(): SensorTap = {
        (prefix, suffix) match {
            case (Some(prefix), Some(suffix)) => SensorTap(prefix, suffix)
            case _ => throw FastScoreError("Unable to build Sensor Tap")
        }
    }
}


class SensorActivateBuilder(
    __type: Option[SensorActivateType.Value] = None,
    _intensityOrInterval: Option[SensorActivateIntensityOrInterval] = None,
    _duration: Option[Double] = None,
    _maxReads: Option[Int] = Some(1)
)(retVal: SensorBuilder) {
    // Required
    private var _type: Option[SensorActivateType.Value] = __type
    // Optional
    private var intensityOrInterval: Option[SensorActivateIntensityOrInterval] = _intensityOrInterval
    private var duration: Option[Double] = _duration
    private var maxReads: Option[Int] = _maxReads

    def withType(_type: SensorActivateType.Value): this.type = {
        this._type = Some(_type)
        this
    }
    def withIntensity(intensity: SensorActivateIntensity): this.type = {
        this.intensityOrInterval = Some(intensity)
        this
    }
    def withInterval(interval: SensorActivateInterval): this.type = {
        this.intensityOrInterval = Some(interval)
        this
    }
    def withDuration(duration: Double): this.type = {
        this.duration = Some(duration)
        this
    }
    def withMaxReads(maxReads: Int): this.type = {
        this.maxReads = Some(maxReads)
        this
    }
    def endActivate(): SensorBuilder = {
        if (this._type.isDefined) retVal else {
            throw FastScoreError(s"Invalid Sensor Activate: type not defined")
        }
    }
    def build(): SensorActivate = {
        _type match {
            case Some(_type) => SensorActivate(_type, intensityOrInterval, duration, maxReads)
            case _ => throw FastScoreError("Unable to build Sensor Activate")
        }
    }
}

class SensorFilterBuilder(
    __type: Option[SensorFilterType.Value] = None,
    _threshold: Option[Either[Int, Double]] = None,
    _minValue: Option[Either[Int, Double]] = None,
    _maxValue: Option[Either[Int, Double]] = None
)(retVal: SensorBuilder) {
    // Required
    private var _type: Option[SensorFilterType.Value] = __type
    private var threshold: Option[Either[Int, Double]] = _threshold
    // Optional
    private var minValue: Option[Either[Int, Double]] = _minValue
    private var maxValue: Option[Either[Int, Double]] = _maxValue

    def withType(_type: SensorFilterType.Value): this.type = {
        this._type = Some(_type)
        this
    }

    def withThreshold(threshold: Int): this.type = {
        this.threshold = Some(Left(threshold))
        this
    }

    def withThreshold(threshold: Double): this.type = {
        this.threshold = Some(Right(threshold))
        this
    }

    def withMinValue(minValue: Int): this.type = {
        this.minValue = Some(Left(minValue))
        this
    }

    def withMinValue(minValue: Double): this.type = {
        this.minValue = Some(Right(minValue))
        this
    }

    def withMaxValue(maxValue: Int): this.type = {
        this.maxValue = Some(Left(maxValue))
        this
    }

    def withMaxValue(maxValue: Double): this.type = {
        this.maxValue = Some(Right(maxValue))
        this
    }
    def endFilter(): SensorBuilder = {
        if (this._type.isDefined && this.threshold.isDefined) retVal else {
            var fields: List[String] = List()
            if (this._type.isEmpty) fields = "Type" :: fields
            if (this.threshold.isEmpty) fields = "Threshold" :: fields
            throw FastScoreError(s"Invalid Sensor Filter: ${fields.mkString(",")} not defined")
        }
    }
    def build(): SensorFilter = {
        (_type, threshold) match {
            case (Some(_type), Some(threshold)) => SensorFilter(_type, threshold, minValue, maxValue)
            case _ => throw FastScoreError("Unable to build Sensor Filter")
        }
    }
}

class SensorAggregateBuilder(
    __type: SensorAggregateType.Value = SensorAggregateType.accumulate,
    _sampleSize: Option[Int] = None
)(retVal: SensorBuilder) {
    private var _type: SensorAggregateType.Value = __type
    private var sampleSize: Option[Int] = _sampleSize

    def withType(_type: SensorAggregateType.Value): this.type = {
        this._type = _type
        this
    }
    def withSampleSize(sampleSize: Int): this.type = {
        this.sampleSize = Some(sampleSize)
        this
    }
    def endAggregate(): SensorBuilder = retVal
    def build(): SensorAggregate = SensorAggregate(_type, sampleSize)
}

class SensorSinkBuilder(
    _sinkType: SensorSinkType.Value = SensorSinkType.pneumo,
    _topic: Option[String] = None,
    _partition: Option[Int] = Some(0)
)(retVal: SensorBuilder) {
    // Required
    private var sinkType: SensorSinkType.Value = _sinkType
    private var topic: Option[String] = _topic
    // Optional
    private var partition: Option[Int] = _partition

    def withType(sinkType: SensorSinkType.Value): this.type = {
        this.sinkType= sinkType
        this
    }
    def withTopic(topic: String): this.type = {
        this.topic = Some(topic)
        this
    }
    def withPartition(partition: Int): this.type = {
        this.partition = Some(partition)
        this
    }
    def endSink(): SensorBuilder = sinkType match {
        case SensorSinkType.pneumo => retVal
        case SensorSinkType.kafka =>
            if (this.topic.isDefined) retVal else throw FastScoreError("Invalid Sensor Sink: topic not defined")
    }
    def build(): SensorSink = sinkType match {
        case SensorSinkType.pneumo => SensorSinkPneumo
        case SensorSinkType.kafka =>
            if (this.topic.isDefined) SensorSinkKafka(topic.get, partition) else throw FastScoreError("Unable to build Sensor Sink")
    }

}

class SensorReportBuilder(_interval: Double = 0.0)(retVal: SensorBuilder) {
    private var interval: Double = _interval

    def withInterval(interval: Double): this.type = {
        this.interval = interval
        this
    }
    def endReport(): SensorBuilder = retVal
    def build(): SensorReport = SensorReport(interval)
}

class SensorBuilder(
    _tapBuilder: Option[SensorBuilder => SensorTapBuilder] = None,
    _activateBuilder: Option[SensorBuilder => SensorActivateBuilder] = None,
    _sinkBuilder: Option[SensorBuilder => SensorSinkBuilder] = None,
    _description: Option[String] = None,
    _filterBuilder: Option[SensorBuilder => SensorFilterBuilder] = None,
    _aggregateBuilder: Option[SensorBuilder => SensorAggregateBuilder] = None,
    _reportBuilder: Option[SensorBuilder => SensorReportBuilder] = None
) {
    // Required
    private var tapBuilder: Option[SensorTapBuilder] = if (_tapBuilder.isDefined) Some(_tapBuilder.get(this)) else None
    private var activateBuilder: Option[SensorActivateBuilder] = if (_activateBuilder.isDefined) Some(_activateBuilder.get(this)) else None
    private var sinkBuilder: Option[SensorSinkBuilder] = if (_sinkBuilder.isDefined) Some(_sinkBuilder.get(this)) else None
    // Optional
    private var description: Option[String] = _description
    private var filterBuilder: Option[SensorFilterBuilder] = if (_filterBuilder.isDefined) Some(_filterBuilder.get(this)) else None
    private var aggregateBuilder: Option[SensorAggregateBuilder] = if (_aggregateBuilder.isDefined) Some(_aggregateBuilder.get(this)) else None
    private var reportBuilder: Option[SensorReportBuilder] = if (_reportBuilder.isDefined) Some(_reportBuilder.get(this)) else None

    def withNewTap(): SensorTapBuilder = {
        this.tapBuilder = Some(new SensorTapBuilder()(this))
        this.tapBuilder.get
    }
    def withNewActivate(): SensorActivateBuilder = {
        this.activateBuilder = Some(new SensorActivateBuilder()(this))
        this.activateBuilder.get
    }
    def withNewSink(): SensorSinkBuilder = {
        this.sinkBuilder = Some(new SensorSinkBuilder()(this))
        this.sinkBuilder.get
    }
    def withDescription(description: String): SensorBuilder = {
        this.description = Some(description)
        this
    }
    def withNewFilter(): SensorFilterBuilder = {
        this.filterBuilder = Some(new SensorFilterBuilder()(this))
        this.filterBuilder.get
    }
    def withNewAggregate(): SensorAggregateBuilder = {
        this.aggregateBuilder = Some(new SensorAggregateBuilder()(this))
        this.aggregateBuilder.get
    }
    def withNewReport(): SensorReportBuilder = {
        this.reportBuilder = Some(new SensorReportBuilder()(this))
        this.reportBuilder.get
    }
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