
from ..errors import FastScoreError

class InstanceBase(object):
    """The parent of all FastScore instance classes.
    """

    def __init__(self, name, api, swg):
        self.name = name
        self.api = api
        self.swg = swg

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

