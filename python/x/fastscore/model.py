
from .mimetypes import MODEL_CONTENT_TYPES, ATTACHMENT_CONTENT_TYPES

from .attachment import Attachment

from .errors import FastScoreError

class Model(object):

    class AttachmentBag(object):
        def __init__(self, model):
            self.model = model

        def names(self):
            return self.model.list_attachments()

        def __getitem__(self, name):
            (datafile,atype) = self.model.get_attachment(name)
            return Attachment(name, atype=atype, datafile=datafile, model=self.model)

        def __delitem__(self, name):
            self.model.remove_attachment(name)

    class SnapshotBag(object):
        def __init__(self, model):
            self.model = model

        def browse(self, date1=None, date2=None, count=None):
            return self.model.list_snapshots(date1, date2, count)

        def __get__(self, snapid):
            return self.model.get_snapshot(snapid)

        def __delitem__(self, snapid):
            self.model.remove_snapshot(snapid)

    def __init__(self, name, mtype='python', source=None, model_manage=None):
        self._name = name
        self.mtype = mtype
        self.source = source
        self._mm = model_manage
        self._attachments = Model.AttachmentBag(self)
        self._snapshots = Model.SnapshotBag(self)

    @property
    def name(self):
        return self._name

    @property
    def mtype(self):
        return self._mtype

    @mtype.setter
    def mtype(self, mtype):
        assert mtype in MODEL_CONTENT_TYPES
        self._mtype = mtype

    @property
    def source(self):
        return self._source

    @source.setter
    def source(self, source):
        self._source = source

    @property
    def attachments(self):
        return self._attachments

    @property
    def snapshots(self):
        return self._snapshots

    def update(self, model_manage=None):
        if model_manage == None and self._mm == None:
            raise FastScore("Model '%s' not associated with Model Manage" % self.name)
        if self._mm == None:
            self._mm = model_manage
        self._mm.save_model(self)

    def saved(self):
        if self._mm == None:
            raise FastScore("Model '%s' not saved (use update() method)" % self.name)

    def list_attachments(self):
        self.saved()
        try:
            return self._mm.api.attachment_list(self._mm.name, self.name)
        except Exception as e:
            raise FastScoreError("Cannot list attachments", caused_by=e)

    def get_attachment(self, name):
        self.saved()
        try:
            (datafile,_,headers) = \
                    self._mm.api.attachment_get_with_http_info(self._mm.name, \
                            self.name, name)
            ct = headers['content-type']
            for atype,ct1 in ATTACHMENT_CONTENT_TYPES.items():
                if ct1 == ct:
                    return (datafile,atype)
            raise FastScoreError("Unrecognized attachment MIME type '%s'" % ct)
        except Exception as e:
            raise FastScoreError("Cannot retrieve attachment '%s'" % name, caused_by=e)

    def remove_attachment(self, name):
        self.saved()
        try:
            self._mm.api.attachment_delete(self._mm.name, self.name, name)
        except Exception as e:
            raise FastScoreError("Cannot remove attachment '%s'" % name, caused_by=e)

    def save_attachment(self, att):
        self.saved()
        try:
            ct = ATTACHMENT_CONTENT_TYPES[att.atype]

            ##
            ## schema: { type: file }
            ##   is not supported by Swagger 2.0 for in-body parameters.
            ##
            with open(att.datafile) as f:
                data = f.read()

            self._mm.api.attachment_put(self._mm.name, \
                    self.name, att.name, data=data, content_type=ct)
        except Exception as e:
           raise FastScoreError("Cannot upload attachment '%s'" % att.name, \
                   caused_by=e)

    def list_snapshots(self, date1, date2, count):
        self.saved()
        try:
            params = {}
            if date1 or date2:
                date_range = ''
                if date1:
                    date_range += date1.isoformat()
                date_range += '--'
                if date2:
                    date_range += date2.isoformat()
                params['date_range'] = date_range
            if count:
                params['count'] = count
            return self._mm.api.snapshot_list(self._mm.name, self.name, **params)
        except Exception as e:
            raise FastScoreError("Cannot list snapshots", caused_by=e)

    def get_snapshot(self, snapid):
        self.saved()
        try:
            return self._mm.api.snapshot_get_metadata(self._mm.name, self.name, snapid)
        except Exception as e:
            raise FastScoreError("Cannot retrieve snapshot '%s' metadata" % snapid, caused_by=e)

    def remove_snapshot(self, snapid):
        self.saved()
        try:
            self._mm.api.snapshot_delete(self._mm.name, self.name, snapid)
        except Exception as e:
            raise FastScoreError("Cannot remove snapshot '%s'" % snapid, caused_by=e)

