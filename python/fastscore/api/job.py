import _service as service
from stream import get_stream
from model import get_model

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
    output_set = deploy_output_stream(output_desc, output_stream, container)
    input_set = deploy_input_stream(input_desc, input_stream, container)
    model_set = deploy_model(model_desc, model, ctype, container)
    if output_set and input_set and model_set:
        print 'Engine is ready to score.'
    return output_set and input_set and model_set

def deploy_model(model_content, model_name, ctype, container=None):
    """
    Deploys the named model to the engine. Returns True if successful.

    Required fields:
    - model_content: The contents of the model.
    - model_name: A name for the model.
    - ctype: The content-type disposition for the model.

    Optional fields:
    - container: The name of the engine container to use, e.g., 'engine-x-1'
    """
    preferred = {service.engine_api_name():container} if container else {}
    headers_model = {"content-type": ctype,
                     "content-disposition": "x-model; name=\"" + model_name + "\""}
    code_model, body_model = service.put_with_headers(service.engine_api_name(),
                             '/1/job/model', headers_model, model_content, preferred=preferred)

    if code_model != 204:
        raise Exception('Error setting model: ' + body_model.decode('utf-8'))
    else:
        print 'Model deployed to engine.'
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
        print 'Input stream set.'
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
        print 'Output stream set.'
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
    chip = ""
    pig_received = False
    outputs = []
    while not pig_received:
        code,body = service.get(service.engine_api_name(), "/1/job/output",
                    preferred=preferred)
        if code != 200:
            raise Exception(body.decode('utf-8'))
        chunk = chip + body
        while True:
            x = chunk.split("\n", 1)
            if len(x) > 1:
                rec = x[0]
                chunk = x[1]
                if rec == pig:
                    pig_received = True
                    break
                elif rec != "": # an artifact of delimited framing
                    outputs.append(rec.decode('utf-8'))
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
