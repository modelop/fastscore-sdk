import json
import _service as service

def list_sensors():
    """
    Returns a list of all of the sensor names in Model Manage.
    """
    code,body = service.get("model-manage", "/1/sensor")
    if code == 200:
        return [x for x in json.loads(body.decode('utf-8'))]
    else:
        raise Exception(body.decode('utf-8'))

def add_sensor(sensor_name, sensor_content):
    """
    Add the named sensor to Model Manage. Returns true if successful.

    Required fields:
    - sensor_name: A name for the sensor in Model Manage.
    - sensor_content: The sensor configuration file (a JSON string).
    """
    ctype = "application/json"
    code,body = service.put("model-manage", "/1/sensor/%s" % sensor_name, ctype, sensor_content)
    if code == 201:
        print "Sensor '%s' added to Model Manage." % sensor_name
        return True
    elif code == 204:
        print "Sensor '%s' updated in Model Manage." %  sensor_name
        return True
    else:
        raise Exception(body.decode('utf-8'))

def get_sensor(sensor_name):
    """
    Retrieve the configuration file of the named sensor from Model Manage.
    Raises a KeyError if no sensor with the specified name can be found.

    Required fields:
    - sensor_name: The name of the sensor to retrieve.
    """
    code,body = service.get("model-manage", "/1/sensor/%s" % sensor_name)
    if code == 200:
        return body.decode('utf-8'),
    elif code == 404:
        raise KeyError("Sensor '%s' not found in Model Manage." % sensor_name)
    else:
        raise Exception(body.decode('utf-8'))

def remove_sensor(sensor_name):
    """
    Delete the named sensor from Model Manage. Returns True if successful.

    Required fields:
    - sensor_name: The name of the sensor to remove.
    """
    code,body = service.delete("model-manage", "/1/sensor/%s" % sensor_name)
    if code == 404:
        raise KeyError("Sensor '%s' not found in Model Manage." % sensor_name)
    elif code == 204:
        print "Sensor '%s' removed from Model Manage." % sensor_name
        return True
    else:
        raise Exception(body.decode('utf-8'))
