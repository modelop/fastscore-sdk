
from .instance import InstanceBase
from ..model import Model
#from ..entity import Model, Attachment, Snapshot
#from ..entity import Stream, Sensor

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

    def __init__(self, name):
        super(ModelManage, self).__init__(name, ModelManageApi())
        self._models = ModelManage.ModelBag(self)

    @property
    def models(self):
        return self._models

    def update(self, entity):
        if type(entity) is Model:
            model = entity
            if model.source == None:
                raise FastScoreError("Model source property not set")
            ct = MODEL_CONTENT_TYPES[model.mtype]
            try:
                self.api.model_put(self.name, model.name, model.source, content_type=ct)
            except Exception as e:
               raise FastScoreError("Cannot save model '%s'" % model.name)
        else:
            ##TODO
            pass

