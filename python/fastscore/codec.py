import json
import titus.datatype
from titus.datatype import jsonEncoder, avroTypeToSchema, jsonToAvroType
from titus.util import ts
import titus.errors
import avro.schema
# record sets:
import pandas as pd
import numpy as np

def to_json(data, schema):
    """
    Serialize the datums in data to JSON, based on the specified AVRO schema.
    Note: Returns an iterator.

    Required fields:
    - data: an iterator, numpy.matrix, pandas.Series, or pandas.DataFrame
            of items to serialize to JSON.
    - schema: The AVRO schema to use (titus.AvroType)
    """
    if isinstance(data, np.matrix):
        for x in data.tolist():
            yield json.dumps(jsonEncoder(schema, x))
    elif isinstance(data, pd.Series):
        for datum in data:
            yield json.dumps(jsonEncoder(schema, datum))
    elif isinstance(data, pd.DataFrame):
        for datum in data.to_dict('records'):
            yield json.dumps(jsonEncoder(schema, datum))
    else:
        for datum in data:
            yield json.dumps(jsonEncoder(schema, datum))

def from_json(data, schema):
    """
    Deserialize the datums in data from JSON, based on the specified AVRO schema.
    Returns an iterator.

    Required fields:
    - data: a list of the items to deserialize (JSON strings)
    - schema: the AVRO schema to use (titus.AvroType)
    """
    for datum in data:
        yield jsonDecoder(schema, json.loads(datum))

def recordset_from_json(data, schema):
    """
    Deserialize the datums in data from JSON into the appropriate record set
    format, using the following rules:
    1. If the inputs are arrays: return numpy.matrix
    2. If the inputs are records: return pandas.DataFrame
    3. If the inputs are scalars: return pandas.Series

    Required fields:
    - data: a list of the items to deserialize (JSON strings)
    - schema: the AVRO schema to use (titus.AvroType)
    """
    recordset = [x for x in from_json(data, schema)]
    if len(recordset) == 0:
        return pd.DataFrame(recordset)
    elif type(recordset[0]) is list:
        return np.matrix(recordset)
    elif type(recordset[0]) is not dict:
        return pd.Series(recordset)
    else:
        return pd.DataFrame(recordset)

def recordset_to_json(recordset, schema):
    """
    Serialize the given record set into JSON, using the appropriate schema.

    Required fields:
    - recordset: a pandas.DataFrame, pandas.Series, or numpy.matrix
    - schema: the Avro schema to use (titus.AvroType)
    """
    return [x for x in to_json(recordset, schema)]

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
