
from os.path import getsize

from .constants import ATTACHMENT_CONTENT_TYPES
from .errors import FastScoreError

class Attachment(object):
    def __init__(self, name, atype=None, datafile=None, datasize=None, model=None):
        self._name = name
        self.atype = atype
        self._datasize = datasize
        self.datafile = datafile
        self._model = model
        if atype == None and datafile != None:
            atype = guess_type(datafile)

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
        if self._datafile == None:
            self._datafile = self._model.download_attachment(self.name)
        return self._datafile

    @datafile.setter
    def datafile(self, datafile):
        self._datafile = datafile
        if datafile:
            self._datasize = getsize(datafile)

    @property
    def datasize(self):
        return self._datasize

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

