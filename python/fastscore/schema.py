import json

from ._schemer import _infer
from .errors import FastScoreError

class SchemaMetadata(object):
    def __init__(self, name):
        self._name = name

    @property
    def name(self):
        return self._name

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

    @staticmethod
    def infer(name, samples, model_manage=None, verbose=False):
        """
        Infer a schema from samples

        :param name: Name of the schema to be inferred
        :param samples: A list of dicts (JSON-encoded samples)

        :param model_manage: (Optional) An instance of Model-Manage to attach the schema to
        """
        schema = _infer(samples, verbose=verbose)
        return Schema(name, source=json.dumps(schema), model_manage=model_manage)


    def update(self, model_manage=None):
        """
        Saves the schema to Model Manage.

        :param model_manage: The Model Manage instance to use. If None, the Model Manage instance
            must have been provided when then schema was created.

        """
        if model_manage == None and self._mm == None:
            raise FastScoreError("Schema '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        return self._mm.save_schema(self)

    def verify(self, engine):
        """
        Asks the engine the check the schema.

        :returns: id of the loaded schema. The identifier can be used to validate
        data records:

        >>> engine = connect.lookup('engine')
        >>> sid = schema.verify(engine)
        >>> engine.validate_data(sid, rec)

        """
        return engine.verify_schema(self)

