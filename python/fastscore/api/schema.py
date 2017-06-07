from . import _service as service
import json

def list_schemata():
    """
    List all the schemata in Model Manage.
    """
    code, body = service.get('model-manage', '/1/schema')
    if code == 200:
        return [x for x in json.loads(body.decode('utf-8'))]
    else:
        raise Exception(body.decode('utf-8'))

def add_schema(schema_name, schema_content):
    """
    Adds a schema to Model Manage. Returns True if successful.

    Required fields:
    - schema_name: A name for the schema.
    - schema_content: The AVRO schema (a JSON object string).
    """
    ctype = "application/json"
    code, body = service.put('model-manage', '/1/schema/%s' % schema_name,
                             ctype, schema_content)
    if code == 201:
        print('Schema \'%s\' added to Model Manage.' % schema_name)
        return True
    elif code == 204:
        print('Schema \'%s\' updated in Model Manage.' % schema_name)
        return True
    else:
        raise Exception(body.decode('utf-8'))

def get_schema(schema_name):
    """
    Retrieves a schema by name from Model Manage. Raises a KeyError if the
    schema cannot be found.

    Required fields:
    - schema_name: The name of the schema in Model Manage.
    """
    code,body = service.get('model-manage', '/1/schema/%s' % schema_name)
    if code == 200:
        return body.decode('utf-8')
    elif code == 404:
        raise KeyError('Schema \'%s\' not found in Model Manage.' % schema_name)
    else:
        raise Exception(body.decode('utf-8'))

def remove_schema(schema_name):
    """
    Removes a named schema from Model Manage. Returns True if successful.

    Required fields:
    - schema_name: The name of the schema to remove.
    """
    code,body = service.delete('model-manage', '/1/schema/%s' % schema_name)
    if code == 404:
        raise KeyError('Schema \'%s\' not found in Model Manage.' % schema_name)
    elif code == 204:
        print('Schema \'%s\' removed from Model Manage.' % schema_name)
        return True
    else:
        raise Exception(body.decode('utf-8'))
