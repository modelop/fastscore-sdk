import json
import titus.datatype
from titus.datatype import jsonEncoder, avroTypeToSchema, jsonToAvroType
from titus.util import ts
import titus.errors

# This is a modified clone of Titus' jsonDecoder function
def jsonDecoder(avroType, value):
    """Decode a JSON object as a given titus.datatype.AvroType.
    :type avroType: titus.datatype.AvroType
    :param avroType: how we want to interpret this JSON
    :type value: dicts, lists, strings, numbers, ``True``, ``False``, ``None``
    :param value: the JSON object in Python encoding
    :rtype: dicts, lists, strings, numbers, ``True``, ``False``, ``None``
    :return: an object ready for PFAEngine.action
    """

    if isinstance(avroType, titus.datatype.AvroNull):
        if value is None:
            return value
    elif isinstance(avroType, titus.datatype.AvroBoolean):
        if value is True or value is False:
            return value
    elif isinstance(avroType, titus.datatype.AvroInt):
        try:
            return int(value)
        except (ValueError, TypeError):
            pass
    elif isinstance(avroType, titus.datatype.AvroLong):
        try:
            return long(value)
        except (ValueError, TypeError):
            pass
    elif isinstance(avroType, titus.datatype.AvroFloat):
        try:
            return float(value)
        except (ValueError, TypeError):
            pass
    elif isinstance(avroType, titus.datatype.AvroDouble):
        try:
            return float(value)
        except (ValueError, TypeError):
            pass
    elif isinstance(avroType, titus.datatype.AvroBytes):
        if isinstance(value, basestring):
            return bytes(value)
    elif isinstance(avroType, titus.datatype.AvroFixed):
        if isinstance(value, basestring):
            out = bytes(value)
            if len(out) == avroType.size:
                return out
    elif isinstance(avroType, titus.datatype.AvroString):
        if isinstance(value, basestring):
            return value
    elif isinstance(avroType, titus.datatype.AvroEnum):
        if isinstance(value, basestring) and value in avroType.symbols:
            return value
    elif isinstance(avroType, titus.datatype.AvroArray):
        if isinstance(value, (list, tuple)):
            return [jsonDecoder(avroType.items, x) for x in value]
    elif isinstance(avroType, titus.datatype.AvroMap):
        if isinstance(value, dict):
            return dict((k, jsonDecoder(avroType.values, v)) for k, v in value.items())
    elif isinstance(avroType, titus.datatype.AvroRecord):
        if isinstance(value, dict):
            out = {}
            for field in avroType.fields:
                if field.name in value:
                    out[field.name] = jsonDecoder(field.avroType, value[field.name])
                elif field.default is not None:
                    out[field.name] = jsonDecoder(field.avroType, field.default)
                elif isinstance(field.avroType, titus.datatype.AvroNull):
                    out[field.name] = None
                else:
                    raise titus.errors.AvroException("{0} does not match schema {1}".format(json.dumps(value), ts(avroType)))
            return out
    elif isinstance(avroType, titus.datatype.AvroUnion):
        if isinstance(value, dict) and len(value) == 1:
            tag, = value.keys()
            val, = value.values()
            types = dict((x.name, x) for x in avroType.types)
            if tag in types:
                return jsonDecoder(types[tag], val) # here is the only change
        elif value is None and "null" in [x.name for x in avroType.types]:
            return None
    else:
        raise Exception
    raise titus.errors.AvroException("{0} does not match schema {1}".format(json.dumps(value), ts(avroType)))
