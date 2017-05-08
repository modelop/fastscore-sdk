
class Schema(object):
    def __init__(self, name, source=None, model_manage=None):
        self._name = name
        self.source = source
        self._mm = model_manage

    @property
    def name(self):
        return self._name

    @property
    def source(self):
        return self._source

    @source.setter
    def source(self, source):
        self._source = source

    def update(self, model_manage=None):
        if model_manage == None and self._mm == None:
            raise FastScore("Schema '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        return self._mm.save_schema(self)

