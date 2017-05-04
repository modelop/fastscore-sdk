
from ..errors import FastScoreError

class InstanceBase(object):
    """The parent of all FastScore instance classes.
    """

    def __init__(self, name, api):
        self.name = name
        self.api = api

    def inspect(self):
        """Retrieve information about the instance including its health.
        """
        try:
            return self.api.health_get(self.name)
        except Exception as e:
            m = "Cannot retrieve instance info"
            raise FastScoreError(m, caused_by=e)

    def get_swagger(self):
        """Retrieves the Swagger API specification.
        """
        try:
            return self.api.swagger_get(self.name)
        except Exception as e:
            m = "Cannot retrieve Swagger specification"
            raise FastScoreError(m, caused_by=e)

