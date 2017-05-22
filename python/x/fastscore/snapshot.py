
class Snapshot(object):
    """
    Represents a snapshot of a model state. Do not create directly. Use the model's snapshots collection:

    >>> model = mm.models['model-1']
    >>> model.snapshots.browse(count=1)
    [{'id': 'yu647a',...}]
    >>> snap = model.snapshots['yu']  # prefix is enough

    """

    def __init__(self, id, date, stype, size, model):
        self._id = id
        self._data = date
        self._stype = stype
        self._size = size
        self._model = model

    @property
    def id(self):
        """
        A snapshot id.
        """
        return self._id

    @property
    def date(self):
        """
        A date the snapshot has been taken.
        """
        return self._date

    @property
    def stype(self):
        return self._stype

    @property
    def size(self):
        """
        A size of the snapshot in bytes.
        """
        return self._size

    def restore(self):
        """
        Restore the model state using the snapshot.

        >>> snap = model.snapshots['yu']  # prefix is enough
        >>> snap.restore()

        """
        self._model.restore_snapshot(self)

