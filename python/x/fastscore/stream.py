
class Stream(object):
    def __init__(self, name, desc=None, model_manage=None):
        self._name = name
        self.desc = desc
        self._mm = model_manage

    @property
    def name(self):
        return self._name

    @property
    def desc(self):
        return self._desc

    @desc.setter
    def desc(self, desc):
        self._desc = desc

    def sample(self, engine, n=None):
        return engine.sample_stream(self.desc, n)

    def update(self, model_manage=None):
        if model_manage == None and self._mm == None:
            raise FastScore("Stream '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        return self._mm.save_stream(self)

