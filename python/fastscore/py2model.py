## -- Model class -- ##
from fastscore.pymodel import PyModel

import re

class Py2Model(PyModel):

    def __init__(self, action, input_schema, output_schema, options={}, begin=None, end=None, functions=[],
                 attachments=[], imports=[], name=None):
        """
        A Python2 Model's constructor.

        Required fields:
        - action: a function
        - input_schema: an input schema to use (fastscore.datatype.AvroType or JSON string)
        - output_schema: an output schema to use (fastscore.datatype.AvroType or JSON string)

        Optional fields:
        - options: options specified by "fastscore.*: " smart comments.
        - begin, end: begin and end functions for the model
        - functions: a list of other user-defined functions needed to execute
                     action, begin, or end
        - attachments: a list of strings with the path to attachments for the
                       model
        - imports: a list of import statements made by the model (as strings)
        - name: a name for this model
        """
        super(Py2Model, self).__init__(action=action,
                                       input_schema=input_schema,
                                       output_schema=output_schema,
                                       options=options,
                                       begin=begin,
                                       end=end,
                                       functions=functions,
                                       attachments=attachments,
                                       imports=imports,
                                       name=name)
        self.model_type = 'python2'
    @staticmethod
    def from_string(model_str, outer_namespace=None):
        return PyModel.from_string(model_str, outer_namespace, Py2Model)
