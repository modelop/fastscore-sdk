
from .mimetypes import ATTACHMENT_CONTENT_TYPES

from .errors import FastScoreError

class Attachment(object):
    def __init__(self, name, atype=None, datafile=None, model=None):
        if datafile == None:
            datafile = name
        if atype == None:
            atype = guess_type(datafile)
        self._name = name
        self.atype = atype
        self.datafile = datafile
        self._model = model

    @property
    def name(self):
        return self._name

    @property
    def atype(self):
        return self._atype

    @atype.setter
    def atype(self, atype):
        assert atype in ATTACHMENT_CONTENT_TYPES
        self._atype = atype

    @property
    def datafile(self):
        return self._datafile

    @datafile.setter
    def datafile(self, datafile):
        self._datafile = datafile

    def upload(self, model=None):
        if model == None and self._model == None:
            raise FastScoreError("Attachment '%s' not associated with a model" % self.name)
        if self._model == None:
            self._model = model
        self._model.save_attachment(self)

def guess_type(datafile):
    if datafile.endswith('.zip'):
        return 'zip'
    elif datafile.endswith('.tar.gz'):
        return 'tgz'
    elif datafile.endswith('.tgz'):
        return 'tgz'
    else:
        raise FastScoreError("Unable to guess attachment type for '%s'" % datafile)

