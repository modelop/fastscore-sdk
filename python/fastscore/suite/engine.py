## -- Engine class -- ##
import json
import fastscore.api as api
import time
from ..codec.datatype import avroTypeToAvroSchema, checkData, jsonNodeToAvroType
from ..codec import to_json, recordset_from_json
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

        Required fields:
        - name: A name for this instance.

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

        Required fields:
        - model: A Model object.

        Optional fields:
        - force_inline: If True, force all attachments to load inline. If False,
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


    ## -- Additional Stuff -- ##

    def score(self, data, use_json=False, statistics=False):
        """
        Scores each datum passed in data.

        Required fields:
        - data: a list of data to score.

        Optional fields:
        - use_json: If True, each datum in data is expected to be a JSON string.
                    (Default: False)
        """
        job_status = api.job_status(self.container)
        if 'model' not in job_status or not job_status['model']:
            raise errors.FastScoreException('No currently running model.')
        input_schema = jsonNodeToAvroType(job_status['model']['input_schema'])
        output_schema = jsonNodeToAvroType(job_status['model']['output_schema'])

        self.input_schema = input_schema
        self.output_schema = output_schema

        input_list = []
        inputs = []
        if use_json:
            inputs = [x for x in data]
        else:
            inputs = [x for x in to_json(data, input_schema)]
            if 'recordsets' in job_status['model']:
                # automatically add a {"$fastscore":"set"} message to the end
                if job_status['model']['recordsets'] == 'input' or \
                   job_status['model']['recordsets'] == 'both':
                    inputs += ['{"$fastscore":"set"}']

        for datum in inputs:
            input_list += [datum.strip()]
        outputs = api.job_input(input_list, self.container)

        if statistics:
            job_status2 = api.job_status(self.container)
            time1 = job_status['jets'][0]['run_time']
            time2 = job_status2['jets'][0]['run_time']
            consumed1 = job_status['jets'][0]['total_consumed']
            consumed2 = job_status2['jets'][0]['total_consumed']
            produced1 = job_status['jets'][0]['total_produced']
            produced2 = job_status2['jets'][0]['total_produced']
            total_time = time2 - time1
            total_consumed = consumed2 - consumed1
            total_produced = produced2 - produced1
            rate_in = total_consumed / total_time
            rate_out = total_produced / total_time
            table = [[total_time, total_consumed, rate_in, total_produced, rate_out]]
            headers = ['time', 'total-in', 'rate-in, rec/s', 'total-out', 'rate-out, rec/s']
            print(tabulate(table, headers=headers))

        if use_json:
            return outputs
        else:
            if json.loads(outputs[-1]) == {"$fastscore": "set"}:
                outputs = outputs[:-1]
            if 'recordsets' in job_status['model'] and \
            (job_status['model']['recordsets'] == 'output' or \
             job_status['model']['recordsets'] == 'both'):
                return recordset_from_json(outputs, output_schema)
            else:
                return [checkData(json.loads(output), output_schema) for output in outputs]
