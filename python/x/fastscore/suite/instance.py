
from ..errors import FastScoreError

class InstanceBase(object):
    """The parent of all FastScore instance classes.
    """

    class ActiveSensorBag(object):
        def __init__(self, inst):
            self._inst = inst

        def __iter__(self):
            for x in self._inst.swg.active_sensor_list(self._inst.name):
                yield x

        def __getitem__(self, tapid):
            return self._inst.swg.active_sensor_describe(self._inst.name, tapid)

        def __delitem__(self, tapid):
            return self._inst.uninstall_sensor(tapid)

    def __init__(self, name, api, swg):
        self.name = name
        self.api = api
        self.swg = swg
        self._active_sensors = InstanceBase.ActiveSensorBag(self)

    @property
    def active_sensors(self):
        return self._active_sensors
   
    @property
    def tapping_points(self):
        return self.swg.active_sensor_available(self.name)

    def check_health(self):
        """Retrieve information about the instance including its health.
        """
        try:
            return self.swg.health_get(self.name)
        except Exception as e:
            raise FastScoreError("Cannot retrieve instance info", caused_by=e)

    def get_swagger(self):
        """Retrieves the Swagger API specification.
        """
        try:
            return self.swg.swagger_get(self.name)
        except Exception as e:
            raise FastScoreError("Cannot retrieve Swagger specification", caused_by=e)

    def install_sensor(self, sensor):
        return self.swg.active_sensor_attach(self.name, sensor.desc)

    def uninstall_sensor(self, tapid):
        self.swg.active_sensor_detach(self.name, tapid)

