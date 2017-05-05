
class Snapshot(object):
    def __init__(self, id, date, stype, size, model):
        self._id = id
        self._data = date
        self._stype = stype
        self._size = size
        self._model = model

    @property
    def id(self):
        return self._id

    @property
    def date(self):
        return self._date

    @property
    def stype(self):
        return self._stype

    @property
    def size(self):
        return self._size

    def restore(self):
        self._model.restore_snapshot(self)

