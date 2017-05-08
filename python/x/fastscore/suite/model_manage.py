
from .instance import InstanceBase
from ..model import Model
from ..schema import Schema
from ..stream import Stream
from ..sensor import Sensor
from ..errors import FastScoreError

from ..constants import MODEL_CONTENT_TYPES

from fastscore.v1 import ModelManageApi

class ModelManage(InstanceBase):
    """A Model Manage instance.
    """

    class ModelBag(object):
        def __init__(self, model_manage):
            self.mm = model_manage

        def names(self):
            try:
                return self.mm.swg.model_list(self.mm.name)
            except Exception as e:
                raise FastScoreError("Cannot list models", caused_by=e)

        def __iter__(self):
            for x in self.mm.swg.model_list(self.mm.name, _return='type'):
                yield x

        def __getitem__(self, name):
            try:
                (source,_,headers) = self.mm.swg.model_get_with_http_info(self.mm.name, name)
            except Exception as e:
                if e.status == 404: # less scary
                    raise FastScoreError("Model '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot retrieve '%s' model" % name, caused_by=e)
            ct = headers['content-type']
            for mtype,ct1 in MODEL_CONTENT_TYPES.items():
                if ct1 == ct:
                    return Model(name, mtype=mtype, source=source, model_manage=self.mm)
            raise FastScoreError("Unexpected model MIME type '%s'" % ct)

        def __delitem__(self, name):
            try:
                self.mm.swg.model_delete(self.mm.name, name)
            except Exception as e:
                if e.status == 404: # less scary
                    raise FastScoreError("Model '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot remove model '%s'" % name, caused_by=e)

    class SchemaBag(object):
        def __init__(self, model_manage):
            self.mm = model_manage

        def names(self):
            try:
                return self.mm.swg.schema_list(self.mm.name)
            except Exception as e:
                raise FastScoreError("Cannot list schemas", caused_by=e)

        def __getitem__(self, name):
            try:
                source = self.mm.swg.schema_get(self.mm.name, name)
            except Exception as e:
                if e.status == 404:
                    raise FastScoreError("Schema '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot retrieve '%s' schema" % name, caused_by=e)
            return Schema(name, source=source, model_manage=self.mm)

        def __delitem__(self, name):
            try:
                self.mm.swg.schema_delete(self.mm.name, name)
            except Exception as e:
                if e.status == 404:
                    raise FastScoreError("Schema '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot remove schema '%s'" % name, caused_by=e)

    class StreamBag(object):
        def __init__(self, model_manage):
            self.mm = model_manage

        def names(self):
            try:
                return self.mm.swg.stream_list(self.mm.name)
            except Exception as e:
                raise FastScoreError("Cannot list streams", caused_by=e)

        def __getitem__(self, name):
            try:
                desc = self.mm.swg.stream_get(self.mm.name, name)
            except Exception as e:
                if e.status == 404:
                    raise FastScoreError("Stream '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot retrieve '%s' stream" % name, caused_by=e)
            return Stream(name, desc, model_manage=self.mm)

        def __delitem__(self, name):
            try:
                self.mm.swg.stream_delete(self.mm.name, name)
            except Exception as e:
                if e.status == 404:
                    raise FastScoreError("Stream '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot remove stream '%s'" % name, caused_by=e)

    class SensorBag(object):
        def __init__(self, model_manage):
            self.mm = model_manage

        def names(self):
            try:
                return self.mm.swg.sensor_list(self.mm.name)
            except Exception as e:
                raise FastScoreError("Cannot list sensors", caused_by=e)

        def __getitem__(self, name):
            try:
                desc = self.mm.swg.sensor_get(self.mm.name, name)
            except Exception as e:
                if e.status == 404:
                    raise FastScoreError("Sensor '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot retrieve '%s' sensor" % name, caused_by=e)
            return Sensor(name, desc=desc, model_manage=self.mm)

        def __delitem__(self, name):
            try:
                self.mm.swg.sensor_delete(self.mm.name, name)
            except Exception as e:
                if e.status == 404:
                    raise FastScoreError("Sensor '%s' not found" % name)
                else:
                    raise FastScoreError("Cannot remove sensor '%s'" % name, caused_by=e)

    def __init__(self, name):
        super(ModelManage, self).__init__(name, 'model-manage', ModelManageApi())
        self._models = ModelManage.ModelBag(self)
        self._schemata = ModelManage.SchemaBag(self)
        self._streams = ModelManage.StreamBag(self)
        self._sensors = ModelManage.SensorBag(self)

    @property
    def models(self):
        return self._models

    @property
    def schemata(self):
        return self._schemata

    @property
    def schemas(self):
        return self._schemata

    @property
    def streams(self):
        return self._streams

    @property
    def sensors(self):
        return self._sensors

    def save_model(self, model):
        if model.source == None:
            raise FastScoreError("Model source property not set")
        ct = MODEL_CONTENT_TYPES[model.mtype]
        try:
            (_,status,_) = self.swg.model_put_with_http_info(self.name,
                                    model.name, model.source, content_type=ct)
            return status == 204
        except Exception as e:
           raise FastScoreError("Cannot save model '%s'" % model.name)

    def save_schema(self, schema):
        if schema.source == None:
            raise FastScoreError("Schema source property not set")
        try:
            (_,status,_) = self.swg.schema_put_with_http_info(self.name,
                                    schema.name, schema.source)
            return status == 204
        except Exception as e:
           raise FastScoreError("Cannot save schema '%s'" % schema.name, caused_by=e)

    def save_stream(self, stream):
        if stream.desc == None:
            raise FastScoreError("Stream descriptor property not set")
        try:
            (_,status,_) = self.swg.stream_put_with_http_info(self.name,
                                    stream.name, stream.desc)
            return status == 204
        except Exception as e:
           raise FastScoreError("Cannot save stream '%s'" % stream.name, caused_by=e)

    def save_sensor(self, sensor):
        if sensor.desc == None:
            raise FastScoreError("Sensor descriptor property not set")
        try:
            (_,status,_) = self.swg.sensor_put_with_http_info(self.name,
                                    sensor.name, sensor.desc)
            return status == 204
        except Exception as e:
           raise FastScoreError("Cannot save sensor '%s'" % model.name, caused_by=e)

