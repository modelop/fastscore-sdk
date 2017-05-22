
class Sensor(object):
    """
    Represents a FastScore sensor. A sensor can be created directly:

    >>> sensor = fastscore.Sensor('sensor-1')
    >>> sensor.desc = {'tap': 'manifold.input.records.size',...}

    Or, retreieved from Model Manage:

    >>> mm = connect.lookup('model-manage')
    >>> mm.sensors['sensor-1']
    >>> mm.desc
    {...}

    """
    def __init__(self, name, desc=None, model_manage=None):
        self._name = name
        self.desc = desc
        self._mm = model_manage

    @property
    def name(self):
        """
        A sensor name.
        """
        return self._name

    @property
    def desc(self):
        """
        A sensor descriptor (a dict).
        """
        return self._desc

    @desc.setter
    def desc(self, desc):
        self._desc = desc

    def install(where):
        """
        Install/attach the sensor.

        :param where: The instance to attach the sensor to.

        """
        where.install_sensor(self)

    def update(self, model_manage=None):
        """
        Saves the sensor to Model Manage.

        :param model_manage: The Model Manage instance to use. If None, the Model Manage instance
            must have been provided when then sensor was created.

        """
        if model_manage == None and self._mm == None:
            raise FastScore("Sensor '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        return self._mm.save_sensor(self)

