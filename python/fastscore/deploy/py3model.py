## -- Model class -- ##
from fastscore.pymodel import PyModel

import re

class Py3Model(PyModel):

    def __init__(self, name, mtype='python3', source=None, model_manage=None, schemas={}, action=None,
         options={}, begin=None, end=None, functions=[], imports=[]):
        """
        A Python3 Model's constructor.

        :param name: A name for the model.
        :param schemas: The input and output schemas for the model.

        :param source: The source code for this model. If specified, then the rest of
          the fields below are ignored.

        :param action: The action method for this model (if not source)
        :param options: options specified by "fastscore.*: " smart comments. (if not source)
        :param begin, end: begin and end functions for the model (if not source)
        :param functions: a list of other user-defined functions needed to execute
                     action, begin, or end (if not source)
        :param imports: a list of import statements made by the model (as strings) (if not source)
        """
        super(Py2Model, self).__init__(name=name,
                                       mtype=mtype,
                                       source=source,
                                       model_manage=model_manage,
                                       schemas=schemas,
                                       action=action,
                                       options=options,
                                       begin=begin,
                                       end=end,
                                       functions=functions,
                                       imports=imports)
    @staticmethod
    def from_string(model_str, outer_namespace=None):
        return PyModel.from_string(model_str, outer_namespace, Py3Model)
