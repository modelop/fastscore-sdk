
class Schema(object):
    """
    An Avro schema. It can be created direct
    """
    def __init__(self, name, source=None, model_manage=None):
        self._name = name
        self.source = source
        self._mm = model_manage

    @property
    def name(self):
        """
        A schema name.
        """
        return self._name

    @property
    def source(self):
        """
        A schema source, e.g. {'type': 'array', 'items': 'int'}.
        """
        return self._source

    @source.setter
    def source(self, source):
        self._source = source

    def update(self, model_manage=None):
        """
        Saves the schema to Model Manage.

        :param model_manage: The Model Manage instance to use. If None, the Model Manage instance
            must have been provided when then schema was created.

        """
        if model_manage == None and self._mm == None:
            raise FastScore("Schema '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        return self._mm.save_schema(self)

