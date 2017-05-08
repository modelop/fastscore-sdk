
class Sensor(object):
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

    def install(where):
        where.install_sensor(self)

    def update(self, model_manage=None):
        if model_manage == None and self._mm == None:
            raise FastScore("Sensor '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        return self._mm.save_sensor(self)

