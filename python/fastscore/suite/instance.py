
from fastscore.live import ActiveSensor

from ..errors import FastScoreError
from ..v1.rest import ApiException

class InstanceBase(object):
    """
    The parent of all FastScore instance classes.
    """

    class ActiveSensorBag(object):
        def __init__(self, inst):
            self._inst = inst

        def ids(self):
            return [ x['id'] for x in self ]

        def __iter__(self):
            try:
                for x in self._inst.swg.active_sensor_list(self._inst.name):
                    yield ActiveSensor(x['id'], x['tap'])
            except Exception as e:
                raise FastScoreError("Cannot retrieve active sensors", caused_by=e)

        def __getitem__(self, tapid):
            try:
                x = self._inst.swg.active_sensor_describe(self._inst.name, tapid)
            except Exception as e:
                if isinstance(e, ApiException) and e.status == 404:
                    raise FastScoreError("Active sensor #%d not found" % tapid)
                else:
                    raise FastScoreError("Cannot retrieve active sensor", caused_by=e)

        def __delitem__(self, tapid):
            return self._inst.uninstall_sensor(tapid)

    def __init__(self, name, api, swg, swg2=None):
        self.name = name
        self.api = api
        self.swg = swg
        self.swg2 = swg2    # REST API v2
        self._active_sensors = InstanceBase.ActiveSensorBag(self)

    @property
    def active_sensors(self):
        """
        A collection of currently installed sensors indexed by id.

        >>> engine = connect.lookup('engine')
        >>> engine.active_sensors.ids()
        [8]
        >>> x = engine.active_sensors[8]
        >>> x.id
        8
        >>> x.tap
        manifold.input.records.count
        >>> x.uninstall()
        >>> engine.active_sensors.ids()
        []

        """
        return self._active_sensors
   
    @property
    def tapping_points(self):
        """
        A list of tapping points supported by the instance.

        >>> mm.tapping_points
        ['sys.memory',... ]

        """
        return self.swg.active_sensor_available(self.name)

    def check_health(self):
        """
        Retrieves version information from the instance. A successful reply indicates
        that the instance is healthy.

        >>> connect.check_health()
        {
          'id': '366e5030-d773-49cb-8b28-9b1b9d173c79',
          'built_on': 'Thu May 11 12:53:39 UTC 2017',
          'release': '1.5'
        }

        """
        try:
            return self.swg.health_get(self.name)
        except Exception as e:
            raise FastScoreError("Cannot retrieve instance info", caused_by=e)

    def get_swagger(self):
        """
        Retrieves the Swagger specification of the API supported by the
        instance.

        >>> connect.get_swagger()
        {u'info':...}

        """
        try:
            return self.swg.swagger_get(self.name)
        except Exception as e:
            raise FastScoreError("Cannot retrieve Swagger specification", caused_by=e)

    def install_sensor(self, sensor):
        return self.swg.active_sensor_attach(self.name, sensor.desc)

    def uninstall_sensor(self, tapid):
        self.swg.active_sensor_detach(self.name, tapid)

