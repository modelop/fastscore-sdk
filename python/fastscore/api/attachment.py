from . import _service as service
from .. import errors
import json
import os

def list_attachments(model_name):
    """
    Lists the names of the attachments associated with the given model.

    Required fields:
    - model_name: The name of the model in Model Manage.
    """
    code,body = service.get('model-manage', '/1/model/%s/attachment' % model_name)
    if code == 200:
        return [x for x in json.loads(body.decode('utf-8'))]
    else:
        raise FastScoreException(body.decode('utf-8'))

def add_attachment(model_name, attachment_file):
    """
    Attaches the specified file to a named model.

    Required fields:
    - model_name: The name of the model in Model Manage.
    - attachment_file: The path to the attachment file.
    """
    if not os.path.exists(attachment_file):
        raise Exception('Attachment %s not found' % attachment_file)
    with open(attachment_file, 'rb') as f:
        data = f.read()
        att_name = os.path.basename(attachment_file)
        code,body = service.put('model-manage',
                                '/1/model/%s/attachment/%s' % (model_name, att_name),
                                _guess_att_ctype(attachment_file), data)
    if code == 201:
        print('Attachment \'%s\' added to model \'%s\'' % (att_name, model_name))
        return True
    elif code == 204:
        print('Attachment \'%s\' updated in model \'%s\'' % (att_name, model_name))
        return True
    else:
        raise FastScoreException(body.decode('utf-8'))

def get_attachment(model_name, attachment_name, attachment_path=''):
    """
    Retrieve the named attachment from a model, and save it to the specified
    location.

    Required fields:
    - model_name: The name of the model in Model Manage.
    - attachment_name: The name of the attachment in Model Manage.

    Optional fields:
    - attachment_path: The local path to save the attachment to. (Default:
                       current working directory).
    """
    code,att_str = service.get_str('model-manage',
                                   '/1/model/%s/attachment/%s' % (model_name, attachment_name))
    if code == 200:
        with open(attachment_path + attachment_name, 'w') as f:
            f.write(att_str.decode('utf-8'))
        print('Attachment saved to %s%s' % (attachment_path, attachment_name))
        return True
    elif code == 404:
        print('Attachment \'%s\' not found' % attachment_name)
        return False
    else:
        raise FastScoreException(att_str.decode('utf-8'))

def remove_attachment(model_name, attachment_name):
    """
    Remove the named attachment from the specified model.

    Required fields:
    - model_name: The name of the model.
    - attachment_name: The name of the attachment.
    """
    code, body = service.delete('model-manage',
                                '/1/model/%s/attachment/%s' % (model_name, attachment_name))
    if code == 204:
        print('Attachment \'%s\' removed from %s' % (attachment_name, model_name))
        return True
    elif code == 404:
        print('Attachment \'%s\' not found' % attachment_name)
        return False
    else:
        raise FastScoreException(body.decode('utf-8'))

def _guess_att_ctype(resource):
    _,ext = os.path.splitext(resource)
    if ext == '.zip':
        return 'application/zip'
    elif ext == '.gz':
        return 'application/gzip'
    else:
        raise FastScoreException('Attachment %s must have the extension .zip or .gz' % resource)
