## -- Engine class -- ##
import json
import time
from ..codec.datatype import avroTypeToAvroSchema, checkData, jsonNodeToAvroType
from ..codec import to_json, from_json, recordset_from_json
import fastscore.errors as errors
from tabulate import tabulate

from binascii import b2a_hex
from os import urandom

from .instance import InstanceBase
from ..constants import MODEL_CONTENT_TYPES, ATTACHMENT_CONTENT_TYPES

from fastscore.v1 import EngineApi
from fastscore import FastScoreError

from ..stream import Stream

class Engine(InstanceBase):
    """
    An Engine instance.
    """

    # Maximum size for an inline attachment.
    MAX_INLINE_ATTACHMENT = 1024*1024

    # A class for tracking input and output stream slots.
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
        """
        Constructor for the Engine class.

        Generally, this is not intended to be constructed 'by hand'. Instead,
        Engine instances should be retrieved from Connect.

        :param name: A name for this instance.

        """
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
        """
        Load a model into this engine.

        :param model: A Model object.
        :param force_inline: If True, force all attachments to load inline. If False,
                        attachments may be loaded by reference.
        """

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


    def score(self, data, encode=True):
        """
        Scores the data on the currently running model. Requires the input and
        output streams to use the REST transport.

        >>> engine.score(data=[1,2,3])
        [4,5,6]
        >>> engine.score(data=['1', '2', '3'], encode=False)
        ['4', '5', '6']

        :param data: The data to score, e.g. a list of JSON records.
        :param encode: A boolean indicating whether to encode the inputs. If
            True, the input data is encoded to JSON, and the output is decoded
            from JSON.
        :returns: The scored data.
        """
        job_status = self.swg.job_status(instance=self.name)
        if job_status.model == None:
            raise FastScoreError("No currently running model.")

        input_schema = jsonNodeToAvroType(job_status.model.input_schema)
        output_schema = jsonNodeToAvroType(job_status.model.output_schema)

        inputs = []
        if not encode:
            inputs = [x for x in data]
        else:
            inputs = [x for x in to_json(data, input_schema)]
            if job_status.model.recordsets == 'both' or \
               job_status.model.recordsets == 'input':
                inputs += ['{"$fastscore":"set"}']

        input_str = ''
        for datum in inputs:
            input_str += datum.strip() + '\n'
        input_str += '{"$fastscore":"pig"}\n'

        # now we send the input
        self.swg.job_io_input(instance=self.name, data=input_str, id=1)

        # now we retrieve the output
        output = self.swg.job_io_output(instance=self.name, id=1)
        if not encode:
            return [x for x in output.split('\n') if len(x) > 0]
        else:
            outputs = [x for x in output.split('\n') if len(x) > 0]
            if json.loads(outputs[-1]) == {"$fastscore": "pig"}:
                outputs = outputs[:-1]
            if json.loads(outputs[-1]) == {"$fastscore": "set"}:
                outputs = outputs[:-1]
            if job_status.model.recordsets == 'both' or \
               job_status.model.recordsets == 'output':
                return recordset_from_json(outputs, output_schema)
            else:
                return [x for x in from_json(outputs, output_schema)]
