
class ActiveSensor(object):
    
    def __init__(self, name, tap):
        self._name = name
        self._tap = tap

    @property
    def name(self):
        return self._name

    @property
    def tap(self):
        return self._tap

