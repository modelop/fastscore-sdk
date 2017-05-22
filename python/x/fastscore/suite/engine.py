
from binascii import b2a_hex
from os import urandom

from .instance import InstanceBase
from ..constants import MODEL_CONTENT_TYPES, ATTACHMENT_CONTENT_TYPES

from fastscore.v1 import EngineApi
from fastscore import FastScoreError

class Engine(InstanceBase):
    """
    An Engine instance.
    """

    MAX_INLINE_ATTACHMENT = 1024*1024

    class SlotBag(object):
        def __init__(self, isinput, engine):
            self._isinput = isinput
            self._eng = engine

        def __setitem__(self, slot, stream):
            if slot != 1:
                raise FastScoreError("Only stream slot 1 is currently supported")
            try:
                if self._isinput:
                    self._eng.swg.input_stream_set(self._eng.name, stream.desc)
                else:
                    self._eng.swg.output_stream_set(self._eng.name, stream.desc)
            except Exception as e:
                raise FastScoreError("Unable to attach stream", caused_by=e)

        def __delitem__(self, slot):
            raise FastScoreError("Not implemented")

    def __init__(self, name):
        super(Engine, self).__init__(name, 'engine', EngineApi())
        self._inputs = Engine.SlotBag(True, self)
        self._outputs = Engine.SlotBag(False, self)
    
    @property
    def inputs(self):
        """
        A collection of input stream slots. Slots are numbered starting with 1.

        >>> mm = connect.lookup('model-manage')
        >>> stream = mm.streams['stream-1']
        >>> engine = connect.lookup('engine')
        >>> engine.inputs[1] = stream

        .. todo:: Detach/close input stream

        """
        return self._inputs

    @property
    def outputs(self):
        """
        A collection of output stream slots. Slots are numbered starting with 1.

        >>> mm = connect.lookup('model-manage')
        >>> stream = mm.streams['stream-1']
        >>> engine = connect.lookup('engine')
        >>> engine.outputs[1] = stream

        .. todo:: Detach/close output stream

        """
        return self._outputs

    def load_model(self, model, force_inline=False):

        def maybe_externalize(att):
            ctype = ATTACHMENT_CONTENT_TYPES[att.atype]
            if att.datasize > Engine.MAX_INLINE_ATTACHMENT and not force_inline:

                ## See https://opendatagoup.atlassian.net/wiki/display/FAS/Working+with+large+attachments
                ##
                ## An example of an externalized attachment:
                ##
                ## Content-Type: message/external-body; access-type=x-model-manage; name="att1.zip"
                ## Content-Disposition: attachment; filename="att1.zip"
                ##
                ## Content-Type: application/zip
                ## Content-Length: 1234
                ##

                ext_type = 'message/external-body; ' + \
                       'access-type=x-model-manage; ' + \
                       'ref="urn:fastscore:attachment:%s:%"' % (model.name,att.name)

                body = 'Content-Type: %s\r\n' % ctype + \
                       'Content-Length: %d\r\n' % att.datasize + \
                       '\r\n'

                return (att.name,body,ext_type)
            else:
                ## data retrieved when you touch .datafile property
                with open(att.datafile) as f:
                    body = f.read()
                return (att.name,body,ctype)

        def quirk(name):
            return 'name' if name == 'x-model' else 'filename'

        def multipart_body(parts, boundary):
            noodle = [
                '\r\n--' + boundary + '\r\n' + \
                'Content-Disposition: %s; %s="%s"\r\n' % (tag,quirk(name),name) + \
                'Content-Type: %s\r\n' % ctype + \
                '\r\n' + \
                body 
                for tag,(name,body,ctype) in parts ]
            noodle.append('\r\n--' + boundary + '--\r\n')
            return ''.join(noodle)

        try:
            ct = MODEL_CONTENT_TYPES[model.mtype]
            attachments = list(model.attachments)
            if len(attachments) == 0:
                data = model.source
                cd = 'x-model; name="%s"' % model.name
                self.swg.model_load(self.name, data, content_type=ct, content_disposition=cd)
            else:
                ## Swagger 2.0 does allow complex multipart requests - craft it manually.
                parts = [ ('attachment',maybe_externalize(x)) for x in attachments ]
                parts.append( ('x-model',(model.name,model.source,ct)) )
                boundary = b2a_hex(urandom(12))
                data = multipart_body(parts, boundary)
                self.swg.model_load(self.name,
                        data, content_type='multipart/mixed; boundary=' + boundary)
        except Exception as e:
            raise FastScoreError("Unable to load model '%s'" % model.name, caused_by=e)

    def unload_model(self):
        try:
            self.swg.job_delete(self.name)
        except Exception as e:
            raise FastScoreError("Unable to unload model", caused_by=e)

    def scale(self, n):
        """
        Changes the number of running model instances.
        """
        try:
            self.swg.job_scale(self.name, n)
        except Exception as e:
            raise FastScoreError("Unable to scale model", caused_by=e)

    def sample_stream(self, stream, n):
        try:
            if n:
                return self.swg.stream_sample(self.name, stream.desc, n=n)
            else:
                return self.swg.stream_sample(self.name, stream.desc)
        except Exception as e:
            raise FastScoreError("Unable to sample stream", caused_by=e)

