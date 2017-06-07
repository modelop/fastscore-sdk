from . import _service as service
import json

def add_model(model_name, model_content, model_type='python2'):
    """
    Adds the specified model to Model Manage. Returns True if successful.

    Required arguments:
    - model_name: a name for the model in Model Manage.
    - model_content: the content of the model (a string)

    Optional arguments:
    - model_type: One of 'python2', 'python3', or 'r'. Default: python2.
    """
    ctype = ''
    if model_type == 'python2':
        ctype = 'application/vnd.fastscore.model-python2'
    elif model_type == 'python3':
        ctype = 'application/vnd.fastscore.model-python3'
    elif model_type == 'r' or model_type == 'R':
        ctype = 'application/vnd.fastscore.model-r'
    elif model_type == 'pfa' or model_type == 'PFA':
        ctype = 'application/vnd.fastscore.model-pfa-json'
    elif model_type == 'PrettyPFA':
        ctype = 'application/vnd.fastscore.model-pfa-pretty'
    else:
        raise ValueError('Unknown model type: %s' % model_type)

    code,body = service.put('model-manage', '/1/model/%s' % model_name,
                            ctype, model_content)
    if code == 201:
        print('Model \'%s\' added to Model Manage.' % model_name)
        return True
    elif code == 204:
        print('Model \'%s\' updated in Model Manage.' % model_name)
        return True
    else:
        raise Exception(body.decode('utf-8'))

def get_model(model_name, include_ctype=False):
    """
    Returns the content of the named model in Model Manage.
    Raises a KeyError if the model cannot be found.

    Required arguments:
    - model_name: The name of the model in Model Manage.

    Optional fields:
    - include_ctype: Whether or not to return the content-type of the model.
    """
    code,body,ctype = service.get_with_ct('model-manage', '/1/model/%s' % model_name)
    if code == 200:
        if include_ctype:
            return body.decode('utf-8'), ctype
        else:
            return body.decode('utf-8')
    elif code == 404:
        raise KeyError('Model not found: \'%s\'' % model_name)
    else:
        raise Exception(body.decode('utf-8'))

def remove_model(model_name):
    """
    Removes the named model from Model Manage.
    Returns True if successful.
    Raises a KeyError if the model cannot be found.

    Required arguments:
    - model_name: The name of the model to remove from Model Manage.
    """
    code,body = service.delete('model-manage', '/1/model/%s' % model_name)
    if code == 404:
        raise KeyError('Model not found: \'%s\'' % model_name)
    elif code == 204:
        print('Model \'%s\' removed from Model Manage.' % model_name)
        return True
    else:
        raise Exception(body.decode('utf-8'))

def list_models():
    """
    Returns a list of the names of all the models in Model Manage.
    """
    code, body = service.get('model-manage', '/1/model?return=type')
    if code == 200:
        t = [ x['name'] for x in json.loads(body.decode('utf-8'))]
        return t
    else:
        raise Exception(body.decode('utf-8'))
