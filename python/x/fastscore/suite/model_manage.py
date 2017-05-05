
from .instance import InstanceBase
from ..model import Model
from ..stream import Stream
from ..sensor import Sensor

from ..mimetypes import MODEL_CONTENT_TYPES

from fastscore.v1 import ModelManageApi

class ModelManage(InstanceBase):
    """A Model Manage instance.
    """

    class ModelBag(object):
        def __init__(self, model_manage):
            self.mm = model_manage

        def names(self):
            try:
                return self.mm.api.model_list(self.mm.name)
            except Exception as e:
                raise FastScoreError("Cannot list models", caused_by=e)

        def __getitem__(self, name):
            try:
                (source,_,headers) = self.mm.api.model_get_with_http_info(self.mm.name, name)
            except Exception as e:
                raise FastScoreError("Cannot retrieve '%s' model" % name, caused_by=e)
            ct = headers['content-type']
            for mtype,ct1 in MODEL_CONTENT_TYPES.items():
                if ct1 == ct:
                    return Model(name, mtype=mtype, source=source, model_manage=self.mm)
            raise FastScoreError("Unexpected model MIME type '%s'" % ct)

        def __delitem__(self, name):
            try:
                self.mm.api.model_delete(self.mm.name, name)
            except Exception as e:
                raise FastScoreError("Cannot remove model '%s'" % name, caused_by=e)

    class StreamBag(object):
        def __init__(self, model_manage):
            self.mm = model_manage

        def names(self):
            try:
                return self.mm.api.stream_list(self.mm.name)
            except Exception as e:
                raise FastScoreError("Cannot list streams", caused_by=e)

        def __getitem__(self, name):
            try:
                desc = self.mm.api.stream_get(self.mm.name, name)
            except Exception as e:
                raise FastScoreError("Cannot retrieve '%s' stream" % name, caused_by=e)
            return Stream(name, desc=desc, model_manage=self.mm)

        def __delitem__(self, name):
            try:
                self.mm.api.stream_delete(self.mm.name, name)
            except Exception as e:
                raise FastScoreError("Cannot remove stream '%s'" % name, caused_by=e)

    class SensorBag(object):
        def __init__(self, model_manage):
            self.mm = model_manage

        def names(self):
            try:
                return self.mm.api.sensor_list(self.mm.name)
            except Exception as e:
                raise FastScoreError("Cannot list sensors", caused_by=e)

        def __getitem__(self, name):
            try:
                desc = self.mm.api.sensor_get(self.mm.name, name)
            except Exception as e:
                raise FastScoreError("Cannot retrieve '%s' sensor" % name, caused_by=e)
            return Sensor(name, desc=desc, model_manage=self.mm)

        def __delitem__(self, name):
            try:
                self.mm.api.sensor_delete(self.mm.name, name)
            except Exception as e:
                raise FastScoreError("Cannot remove sensor '%s'" % name, caused_by=e)

    def __init__(self, name):
        super(ModelManage, self).__init__(name, ModelManageApi())
        self._models = ModelManage.ModelBag(self)
        self._streams = ModelManage.StreamBag(self)
        self._sensors = ModelManage.SensorBag(self)

    @property
    def models(self):
        return self._models

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
            self.api.model_put(self.name, model.name, model.source, content_type=ct)
        except Exception as e:
           raise FastScoreError("Cannot save model '%s'" % model.name)

    def save_stream(self, stream):
        if stream.desc == None:
            raise FastScoreError("Stream descriptor property not set")
        try:
            self.api.stream_put(self.name, stream.name, stream.desc)
        except Exception as e:
           raise FastScoreError("Cannot save stream '%s'" % model.name)

    def save_sensor(self, sensor):
        if sensor.desc == None:
            raise FastScoreError("Sensor descriptor property not set")
        try:
            self.api.sensor_put(self.name, sensor.name, sensor.desc)
        except Exception as e:
           raise FastScoreError("Cannot save sensor '%s'" % model.name)

