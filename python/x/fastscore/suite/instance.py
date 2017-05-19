
from ..errors import FastScoreError

import yaml

class InstanceBase(object):
    """
    The parent of all FastScore instance classes.
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
        """
        A collection of currently installed sensors indexed by tapid.

        >>> engine = connect.lookup('engine')
        >>> list(engine.active_sensors)
        [
          {
            'id': 8,
            'tap': 'manifold.input.records.count',
            'active': False     # not currently active
          },
          ...
        ]
        >>> engine.active_sensors[8]
        {
          'id': 8,
          'tap': 'manifold.input.records.count',
          'permanent': True     # 'permanent' activation schedule
        }
        >>> del engine.active_sensors[8]

        """
        return self._active_sensors
   
    @property
    def tapping_points(self):
        """
        A list of supported tapping points.

        >>> mm.tapping_points
        ['sys.memory',... ]

        """
        return self.swg.active_sensor_available(self.name)

    def check_health(self):
        """
        Retrieve information about the instance. A successful reply indicates
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
            spec = self.swg.swagger_get(self.name, accept='application/x-yaml')
            return yaml.load(spec)
        except Exception as e:
            raise FastScoreError("Cannot retrieve Swagger specification", caused_by=e)

    def install_sensor(self, sensor):
        return self.swg.active_sensor_attach(self.name, sensor.desc)

    def uninstall_sensor(self, tapid):
        self.swg.active_sensor_detach(self.name, tapid)

