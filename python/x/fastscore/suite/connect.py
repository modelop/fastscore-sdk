
from fastscore.v1 import configuration
from fastscore.v1 import ConnectApi

from .instance import InstanceBase
from .model_manage import ModelManage
from .engine import Engine
from ..errors import FastScoreError

from urlparse import urlparse
import yaml

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class Connect(InstanceBase):
    """A reference to a Connect instance.
    """

    def __init__(self, proxy_prefix):
        # https://localhost/api/1/service
        x = urlparse(configuration.host)
        base_path = x.path
        configuration.host = proxy_prefix + base_path
        configuration.verify_ssl = False
        super(Connect, self).__init__('connect', ConnectApi())
        self.resolved = {}
        self.preferred = {}
        self.target = None

    def lookup(self, sname):
        """Retrieves an preferred/default instance of a named service.

        Args:
            sname: A FastScore service name, e.g. 'model-manage'.
        Returns:
            A FastScore instance object.
        """
        if sname in self.preferred:
            return self.get(self.preferred[sname])
        try:
            xx = self.api.connect_get(self.name, api=sname)
        except Exception as e:
            m = "Cannot retrieve fleet info"
            raise FastScoreError(m, caused_by=e)
        for x in xx:
            if x.health == 'ok':
                return self.get(x.name)
        if len(xx) == 0:
            m = "No instances of service '%s' configured" % sname
        elif len(xx) == 1:
            m = "'%s' instance is unhealthy" % xx[0].name
        else:
            m = "All %d instances of service '%s' are unhealthy" % len(xx)
        raise FastScoreError(m)

    def get(self, name):
        """Retrieves a (cached) reference to the named instance.

        Args:
            name: A FastScore instance name.
        Returns:
            A FastScore instance object.
        """
        if name == 'connect':
            return self
        if name in self.resolved:
            return self.resolved[name]
        try:
            xx = self.api.connect_get(self.name, name=name)
        except Exception as e:
            m = "Cannot retrieve '%s' instance info"
            raise FastScoreError(m, caused_by=e)
        if len(xx) > 0 and xx[0].health == 'ok':
            x = xx[0]
            instance = make_instance(x.api, name)
            self.resolved[name] = instance
            return instance
        if len(xx) == 0:
            m = "Instance '%s' not found" % name
        else:
            m = "Instance '%s' is unhealthy" % name
        raise FastScoreError(m)

    def prefer(self, sname, name):
        """Marks the named instance as preferred for a given service.

        Args:
            sname: A FastScore service name, e.g. 'model-manage'.
            name: The name of preferred instance of the given service.
        """
        self.preferred[sname] = name

    def configure(self, config):
        """Sets the FastScore configuration.

        Args:
            config: A dict describing a FastScore configuration.
        """
        try:
            self.api.config_put(self.name, \
                config=yaml.dump(config), \
                content_type='application/x-yaml')
        except Exception as e:
            m = "Cannot set the FastScore configuration"
            raise FastScoreError(m, caused_by=e)

    def get_config(self, section=None):
        """Retrieves the current FastScore configuration.

        Args:
            section: Gets only the named section of the configuration
        Returns:
            A dict with the FastScore configuration.
        """
        try:
            if section:
                return self.api.config_get(self.name, \
                    q=section, \
                    accept='application/x-yaml')
            else:
                return self.api.config_get(self.name, \
                    accept='application/x-yaml')
        except Exception as e:
            m = "Cannot read the FastScore configuration"
            raise FastScoreError(m, caused_by=e)

    def fleet(self):
        """Retrieve metadata of all running instances.
        """
        try:
            return self.api.connect_get(self.name)
        except Exception as e:
            raise FatsScoreError("Cannot retrieve fleet info", caused_by=e)

def make_instance(api, name):
    if api == 'model-manage':
        return ModelManage(name)
    else:
        assert api == 'engine'
        return Engine(name)
        
