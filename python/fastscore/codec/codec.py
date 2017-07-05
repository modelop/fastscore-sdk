import json
from .datatype import jsonEncoder, jsonDecoder, avroTypeToAvroSchema, jsonToAvroType
import avro.schema
# record sets:
import pandas as pd
import numpy as np

def to_json(data, schema):
    """
    Serialize the datums in data to JSON, based on the specified AVRO schema.
    Note: Returns an iterator.

    >>> inputs = [{'a':2}, {'a':3}]
    >>> [x for x in to_json(inputs, input_schema)]
    ['{"a":2}', '{"a":3}']

    :param data: an iterator, numpy.matrix, pandas.Series, or pandas.DataFrame
            of items to serialize to JSON.
    :param schema: The AVRO schema to use (codec.datatype.AvroType)
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

    >>> outputs = ['{"int":3}', '{"string":"a"}', '{"int":4}']
    >>> [x for x in from_json(outputs, output_schema)]
    [3, 'a', 4]

    :param data: a list of the items to deserialize (JSON strings)
    :param schema: the AVRO schema to use (codec.datatype.AvroType)
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

    :param data: a list of the items to deserialize (JSON strings)
    :param schema: the AVRO schema to use (datatype.AvroType)
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

    :param recordset: a pandas.DataFrame, pandas.Series, or numpy.matrix
    :param schema: the Avro schema to use (datatype.AvroType)
    """
    return [x for x in to_json(recordset, schema)]
