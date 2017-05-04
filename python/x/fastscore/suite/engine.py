
from .instance import InstanceBase

from fastscore.v1 import EngineApi

class Engine(InstanceBase):
    """An Engine instance.
    """

    def __init__(self, name):
        super(Engine, self).__init__(name, EngineApi())

