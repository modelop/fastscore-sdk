## -- Model class -- ##
from inspect import getsource
import json
import collections
from fastscore.datatype import jsonToAvroType, checkData, Type, avroTypeToSchema
from fastscore.utils import compare_items
from fastscore.codec import to_json, from_json, recordset_from_json
import types
import time

import re

class Model(object):

    def __init__(self, input_schema, output_schema, attachments=[], name=None, model_type=None):
        """
        A generic Model's constructor.

        Required fields:
        - input_schema: an input schema to use (titus.datatype.AvroType or JSON string)
        - output_schema: an output schema to use (titus.datatype.AvroType or JSON string)

        Optional fields:
        - name: a name for this model
        - attachments: a list of strings with the path to attachments for the
          model
        - model_type: the language for this model (e.g., 'python3')
        """

        self.attachments = attachments
        self.input_schema = input_schema
        self.output_schema = output_schema
        self.model_type = model_type
        if name:
            self.name = name
        else:
            self.name = 'model_' + str(int(time.time()))

    @property
    def input_schema(self):
        return self.__input_schema

    @input_schema.setter
    def input_schema(self, input_schema):
        if type(input_schema) is str:
            self.__input_schema = jsonToAvroType(input_schema)
        elif isinstance(input_schema, Type):
            self.__input_schema = input_schema
        else:
            raise TypeError("Model input schema must be either a JSON string or AvroType")

    @input_schema.deleter
    def input_schema(self):
        del self.__input_schema

    @property
    def output_schema(self):
        return self.__output_schema

    @output_schema.setter
    def output_schema(self, output_schema):
        if type(output_schema) is str:
            self.__output_schema = jsonToAvroType(output_schema)
        elif isinstance(output_schema, Type):
            self.__output_schema = output_schema
        else:
            raise TypeError("Model output schema must be either a JSON string or AvroType")

    @output_schema.deleter
    def output_schema(self):
        del self.__output_schema

    def to_string(self):
        """
        Convert this model object to a string, ready for use in FastScore.
        """

        return self.__model_string

    def score(self, inputs, complete=True, use_json=False):
        """
        Scores data using this model. This must be implemented by any child
        classes!

        Required fields:
        - inputs: The input data. This can be either a single item, or an
                  iteratable collection of items (e.g. a list)

        Optional fields:
        - complete: A boolean. If True, execute 'begin()' at the start and
                    'end()' at the end (default). If False, skip executing
                    'begin()' and 'end()'
        - use_json: If True, inputs and outputs are JSON strings. Default: False.
        """
        raise NotImplementedError('Model score methods must be implemented by child classes.')


    def validate(self, inputs, outputs, use_json=False):
        """
        Validates that the model produces the expected outputs from the input
        data, and that input and output data match the schema.

        Note: Model Validation must be implemented by child classes.

        Required fields:
        - inputs: Input data to be scored.
        - outputs: The expected output of the model associated to the given
                   inputs.

        Optional fields:
        - use_json: True if inputs and outputs are JSON strings. Default: False.
        """
        raise NotImplementedError('Model validation methods must be implemented by child classes.')


    @classmethod
    def from_string(model_str):
        """
        Creates a Model object from a string.

        Required fields:
        - model_str: A string of code defining the model.
        """
        input_schema = '"null"'
        output_schema = '"null"'
        mymodel = Model(input_schema=input_schema, output_schema=output_schema)
        mymodel.__model_string = model_str
        return mymodel
