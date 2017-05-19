from . import _service as service
from .attachment import list_attachments
from .stream import get_stream
from .model import get_model
from .. import errors
import json

def run_job(model, input_stream, output_stream, container=None):
    """
    Runs the named model using the specified input and output streams.
    Returns True if deployment is successful.

    Required fields:
    - model: The name of the model in Model Manage.
    - input_stream: The name of the input stream descriptor.
    - output_stream: The name of the output stream descriptor.

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    """
    input_desc = get_stream(input_stream)
    output_desc = get_stream(output_stream)
    model_desc, ctype = get_model(model, include_ctype=True)
    attachments = [_get_att(model, att_name) for att_name in list_attachments(model) ]
    output_set = deploy_output_stream(output_desc, output_stream, container)
    input_set = deploy_input_stream(input_desc, input_stream, container)
    model_set = deploy_model(model_desc, model, ctype, attachments, container)
    if output_set and input_set and model_set:
        print('Engine is ready to score.')
    return output_set and input_set and model_set

def deploy_model(model_content, model_name, ctype, attachments = [], container=None):
    """
    Deploys the named model to the engine. Returns True if successful.

    Required fields:
    - model_content: The contents of the model.
    - model_name: A name for the model.
    - ctype: The content-type disposition for the model.

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    - attachments: A list of attachments to include.
    """
    preferred = {service.engine_api_name():container} if container else {}

    parts = [ ('attachment', x) for x in attachments]
    parts.append( ('x-model', (model_name, model_content, ctype)) )

    code_model, body_model = service.put_multi(service.engine_api_name(), '/1/job/model', parts, preferred=preferred)

    if code_model != 204:
        raise Exception('Error setting model: ' + body_model.decode('utf-8'))
    else:
        print('Model deployed to engine.')
        return True
    return

def deploy_input_stream(stream_content, stream_name, container=None):
    """
    Deploys the named stream to the engine (input). Returns True if successful.

    Required fields:
    - stream_content: The contents of the stream.
    - stream_name: A name for this stream.

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    """
    preferred = {service.engine_api_name():container} if container else {}
    headers_in = {"content-type": "application/json",
              "content-disposition": "x-stream; name=\"" + stream_name + "\""}
    code_in,body_in = service.put_with_headers(service.engine_api_name(),
                      '/1/job/stream/in', headers_in, stream_content, preferred=preferred)
    if code_in != 204:
        raise Exception('Error setting input stream: ' + body_in.decode('utf-8'))
    else:
        print('Input stream set.')
        return True

def deploy_output_stream(stream_content, stream_name, container=None):
    """
    Deploys the named stream to the engine (output). Returns True if successful.

    Required fields:
    - stream_content: The contents of the stream.
    - stream_name: A name for this stream.

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    """
    preferred = {service.engine_api_name():container} if container else {}
    headers_out = {"content-type": "application/json",
                "content-disposition": "x-stream; name=\"" + stream_name + "\""}
    code_out, body_out = service.put_with_headers(service.engine_api_name(),
                         '/1/job/stream/out', headers_out, stream_content, preferred=preferred)
    if code_out != 204:
        raise Exception('Error setting output stream: ' + body_out.decode('utf-8'))
    else:
        print('Output stream set.')
        return True

def job_input(input_data, container=None):
    """
    Send inputs to the engine for scoring, and return the results.

    Required fields:
    - input_data: The data to send to the engine for scoring. (A list of
                  JSON strings).

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    """
    preferred = {service.engine_api_name():container} if container else {}
    pig = '{"$fastscore":"pig"}'
    data = '\n'.join(input_data) + '\n' + pig + '\n'
    code,body = service.post(service.engine_api_name(), '/1/job/input', data=data,
                preferred=preferred)
    if code != 204:
        raise Exception(body.decode('utf-8'))
    chip = ''
    pig_received = False
    outputs = []
    while not pig_received:
        code,body = service.get(service.engine_api_name(), "/1/job/output",
                    preferred=preferred)
        if code != 200:
            raise Exception(body.decode('utf-8'))
        chunk = chip + body.decode('utf-8')
        while True:
            x = chunk.split("\n", 1)
            if len(x) > 1:
                rec = x[0]
                chunk = x[1]
                if rec == pig:
                    pig_received = True
                    break
                elif rec != "": # an artifact of delimited framing
                    outputs.append(rec)
            else:
                chip = x[0]
                if chip == pig:
                    pig_received = True
                break
    return outputs

def stop_job(container=None):
    """
    Stop the current job. Returns True if successful.

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    """
    preferred = {service.engine_api_name():container} if container else {}
    code,body = service.delete(service.engine_api_name(), "/1/job", preferred=preferred)
    if code != 204:
        raise Exception(body.decode('utf-8'))
    return True

def job_status(container=None):
    """
    Retrieve the status of the currently running job on the specified engine.
    The result is a JSON object whose top-level fields are:
    * 'jets': Information about the current jets. Each jet has the following
            fields:
            * 'busy': A boolean indicating if the jet is currently busy.
            * 'total_consumed': An integer counting the total number of inputs.
            * 'total_produced': An integer counting the total number of outputs.
            * 'pid': An integer indicating the process ID for this jet.
            * 'sandbox': An integer indicating the sandbox used by this jet.
            * 'run_time': A float indicating how long, in seconds, this jet has been running.
            * 'memory': An integer indicating how much memory this jet is using.
    * 'model': The content of the currently running model. Fields:
            * 'name': The name of the current model.
            * 'input_schema': The model's input Avro schema.
            * 'output_schema': The model's output Avro schema.
            * 'source': The source code of the model.
            * 'recordsets': Whether the model uses record sets.
            * 'type': The language of the model (e.g., 'python')
            * 'attachments': A list of the model's attachments.
    * 'input': Information about the model's input. Fields:
            * 'records': The number of input records received.
            * 'rej_sample': A sample of the rejected input records.
            * 'bytes': The number of bytes of input records received.
            * 'name': The name of the input stream descriptor.
            * 'rej_records': The number of records rejected from this stream.
    * 'output': Information about the model's output. Fields:
            * 'records': The number of input records received.
            * 'rej_sample': A sample of the rejected input records.
            * 'bytes': The number of bytes of output records received.
            * 'name': The name of the output stream descriptor.
            * 'rej_records': The number of records rejected from this stream.

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    """
    preferred = {service.engine_api_name():container} if container else {}
    code,body = service.get(service.engine_api_name(), '/1/job/status', preferred=preferred)
    if code == 200:
        return json.loads(body.decode('utf-8'))
    else:
        raise errors.FastScoreException(body.decode('utf-8'))

def _get_att(model_name, att_name):
    """
    Return the externalized attachment. Result is a tuple with the following
    fields:
    - attachment_name
    - attachment_body
    - ext_type
    """
    code, headers = service.head('model-manage', '/1/model/%s/attachment/%s' % (model_name, att_name))
    if code != 200:
        raise errors.FastScoreException('Unable to retrieve attachment.')
    ctype = headers['content-type']
    size = int(headers['content-length'])
    ext_type = 'message/external-body; ' + \
               'access-type=x-model-manage; ' + \
               'ref="urn:fastscore:attachment:%s:%s"' % (model_name, att_name)
    body = 'Content-Type: %s\r\n' % ctype + \
           'Content-Disposition: attachment; filename="%s"\r\n' % att_name + \
           'Content-Length: %d\r\n' % size + \
           '\r\n'
    return (att_name, body, ext_type)
