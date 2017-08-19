
class StreamMetadata(object):
    def __init__(self, name):
        self._name = name

    @property
    def name(self):
        return self._name

class Stream(object):
    """
    A FastScore stream. A stream can be created directly:

    >>> stream = fastscore.stream('stream-1')
    >>> stream.desc = {'Transport':...}

    Or, retrieved from a Model Manage instance:

    >>> mm = connect.lookup('model-manage')
    >>> stream = mm.streams['stream-1']

    """

    def __init__(self, name, desc=None, model_manage=None):
        self._name = name
        self.desc = desc
        self._mm = model_manage

    @property
    def name(self):
        """
        A stream name.
        """
        return self._name

    @property
    def desc(self):
        """
        A stream descriptor (a dict).

        >>> stream = mm.streams['stream-1']
        >>> stream.desc
        {'Transport': {'Type': 'discard'}, 'Encoding': 'json'}

        """
        return self._desc

    @desc.setter
    def desc(self, desc):
        self._desc = desc

    def sample(self, engine, n=None):
        """
        Retrieves a few sample records from the stream.

        :param engine: An Engine instance to use.
        :param n: A number of records to retrieve (default: 10).
        :returns: An array of base64-encoded records.

        """
        return engine.sample_stream(self, n)

    def update(self, model_manage=None):
        """
        Saves the stream to Model Manage.

        :param model_manage: The Model Manage instance to use. If None, the Model Manage instance
            must have been provided when then stream was created.

        """
        if model_manage == None and self._mm == None:
            raise FastScore("Stream '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        return self._mm.save_stream(self)

    def attach(self, engine, slot):
        """
        Attach the stream to the engine.
        
        :param slot: The stream slot.

        """
        engine.attach_stream(self, slot)

