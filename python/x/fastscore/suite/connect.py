
from ..v1 import configuration
from ..v1 import ConnectApi

from .instance import InstanceBase
from .model_manage import ModelManage
from .engine import Engine
from ..errors import FastScoreError

from ..pneumo import PneumoSock

from urlparse import urlparse
import yaml

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class Connect(InstanceBase):
    """An instance of a Connect service.

    Typically, interaction with FastScore starts as follows:

    >>> from fastscore.suite import Connect
    >>> connect = Connect("https://localhost:8000")

    Afterwards, you can use 'connect' to access other FastScore instances.
    For example,

    >>> engine = connect.lookup('engine') 

    """

    def __init__(self, proxy_prefix):
        """
        :param proxy_prefix: URL of the FastScore proxy endpoint
        """

        # https://localhost/api/1/service
        x = urlparse(configuration.host)
        base_path = x.path
        configuration.host = proxy_prefix + base_path
        configuration.verify_ssl = False
        super(Connect, self).__init__('connect', 'connect', ConnectApi())
        self._proxy_prefix = proxy_prefix
        self._resolved = {}
        self._preferred = {}
        self._target = None

    @property
    def target(self):
        """
        Gets/Sets the target instance. When set, the target instance also
        becomes the preferred instance of the service it represents.

        >>> engine = connect.get('engine-3')
        >>> connect.target = engine

        """
        return self._target

    @target.setter
    def target(self, instance):
        self.prefer(instance.api, instance.name)
        self._target = instance

    def pneumo(self):
        """
        Creates a Pneumo socket. See :class:`.PneumoSock`.
        """
        try:
            return PneumoSock(self._proxy_prefix)
        except Exception as e:
            raise FastScoreError("Unable to open Pneumo connection", caused_by=e)

    def lookup(self, sname):
        """
        Retrieves an preferred/default instance of a named service.

        :param sname: a FastScore service name, e.g. 'model-manage'.
        :returns: a FastScore instance object.
        """
        if sname in self._preferred:
            return self.get(self._preferred[sname])
        try:
            xx = self.swg.connect_get(self.name, api=sname)
        except Exception as e:
            raise FastScoreError("Cannot retrieve fleet info", caused_by=e)
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
        """
        Retrieves a (cached) reference to the named instance.

        :param name: a FastScore instance name.
        :returns: a FastScore instance object.
        """
        if name == 'connect':
            return self
        if name in self._resolved:
            return self._resolved[name]
        try:
            xx = self.swg.connect_get(self.name, name=name)
        except Exception as e:
            raise FastScoreError("Cannot retrieve '%s' instance info" % name, caused_by=e)
        if len(xx) > 0 and xx[0].health == 'ok':
            x = xx[0]
            instance = Connect.make_instance(x.api, name)
            self._resolved[name] = instance
            return instance
        if len(xx) == 0:
            m = "Instance '%s' not found" % name
        else:
            m = "Instance '%s' is unhealthy" % name
        raise FastScoreError(m)

    def prefer(self, sname, name):
        """
        Marks the named instance as preferred for a given service.

        >>> connect.prefer('engine', 'engine-3')

        :param sname: a FastScore service name, e.g. 'model-manage'.
        :param name: the name of preferred instance of the given service.
        """
        self._preferred[sname] = name

    def configure(self, config):
        """
        Sets the FastScore configuration.

        >>> with open('config.yaml') as f: 
        >>>   connect.configure(yaml.load(f))

        :param config: a dict describing a FastScore configuration.
        :returns: True if an existing configuration has been replaced and False
            otherwise.
        """
        try:
            (_,status,_) = self.swg.config_put_with_http_info(self.name, \
                config=config, \
                content_type='application/x-yaml')
            return status == 204
        except Exception as e:
            raise FastScoreError("Cannot set the FastScore configuration", caused_by=e)

    def get_config(self, section=None):
        """
        Retrieves the current FastScore configuration.

        >>> connect.config('db')
        {
          'username': 'root',
          'host': 'database',
          'password': 'root',
          'type': 'mysql',
          'port': 3306
        }

        :param section: gets only the named section of the configuration
        :returns: a dict with the FastScore configuration.
        """
        try:
            if section:
                conf = self.swg.config_get(self.name, \
                    q=section, \
                    accept='application/x-yaml')
            else:
                conf = self.swg.config_get(self.name, \
                    accept='application/x-yaml')
            return yaml.load(conf)
        except Exception as e:
            if e.status == 404:
                return None ## not yet configured
            raise FastScoreError("Cannot retrieve configuration", caused_by=e)

    def fleet(self):
        """
        Retrieves metadata for all running instances.

        :returns: an array of dicts describing running FastScore instances. Each
            dict contains the following fields:

            * api: the service name, e.g. 'model-manage'
            * built_on: the human-readable build date and time
            * health: the current health status of the instance.
            * host: the host name of the instance REST API
            * port: the port of the instance REST API
            * release: the instance release, e.g '1.5'
            * id: the internal instance id (do not use)
        """
        try:
            return self.swg.connect_get(self.name)
        except Exception as e:
            raise FastScoreError("Cannot retrieve fleet info", caused_by=e)

    @staticmethod
    def make_instance(api, name):
        if api == 'model-manage':
            return ModelManage(name)
        else:
            assert api == 'engine'
            return Engine(name)

    def dump(self, savefile):
        """
        Saves the Connect parameters to a file.

        >>> connect.dump(".fastscore")

        """
        try:
            cap = {
                'proxy-prefix': self._proxy_prefix,
                'preferred':    self._preferred,
                'target-name':  self.target.name if self.target else None
            }
            with open(savefile, "w") as f:
                yaml.dump(cap, stream = f)
        except Exception as e:
            raise FastScoreError("Unable to save Connect info", caused_by=e)

    @staticmethod
    def load(savefile):
        """
        Recreates a Connect instance from a file.

        >>> connect = Connect.load(".fastscore")

        """
        try:
            with open(savefile, "r") as f:
                cap = yaml.load(f)
                co = Connect(cap['proxy-prefix'])
                co._preferred = cap['preferred']
                if cap['target-name']:
                    co.target = co.get(cap['target-name'])
                return co
        except Exception as e:
            raise FastScoreError("Unable to recreate a Connect instance", caused_by=e)
        
