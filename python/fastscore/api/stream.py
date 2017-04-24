import _service as service
import json

def list_streams():
    """
    Retrieve a list of the stream descriptors currently loaded in Model Manage.
    """
    code,body = service.get('model-manage', '/1/stream')
    if code == 200:
        return [x for x in json.loads(body.decode('utf-8'))]
    else:
        raise Exception(body.decode('utf-8'))

def add_stream(stream_name, stream_content):
    """
    Add or update a stream descriptor to Model Manage. Returns True
    if successful.

    Required fields:
    - stream_name: A name for the stream descriptor.
    - stream_content: The content of the descriptor (a JSON string)
    """
    ctype = 'application/json'
    code,body = service.put('model-manage', '/1/stream/%s' % stream_name,
                            ctype, stream_content)
    if code == 201:
        print 'Stream \'%s\' added to Model Manage.' % stream_name
        return True
    elif code == 204:
        print 'Stream \'%s\' updated in Model Manage.' % stream_name
        return True
    else:
        raise Exception(body.decode('utf-8'))

def get_stream(stream_name):
    """
    Retrieve the named stream descriptor from Model Manage.
    Raises a KeyError if the stream cannot be found.

    Required fields:
    - stream_name: A name for the stream descriptor.
    """
    code,body = service.get('model-manage', '/1/stream/%s' % stream_name)
    if code == 200:
        return body.decode('utf-8')
    elif code == 404:
        raise KeyError('Stream \'%s\' not found in Model Manage.' % stream_name)
    else:
        raise Exception(body.decode('utf-8'))

def remove_stream(stream_name):
    """
    Remove the named stream from Model Manage. Returns True if successful.
    Raises a KeyError if the stream cannot be found.

    Required fields:
    - stream_name: the name of the stream to remove.
    """
    code,body = service.delete('model-manage', '/1/stream/%s' % stream_name)
    if code == 404:
        raise KeyError('Stream \'%s\' not found in Model Manage' % stream_name)
    elif code == 204:
        print 'Stream \'%s\' removed from Model Manage.' % stream_name
        return True
    else:
        raise Exception(body.decode('utf-8'))
