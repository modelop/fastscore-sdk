## -- Model class -- ##
from ..model import Model
from ..schema import Schema
from ..stream import Stream

from inspect import getsource
import json
import collections
from ..codec.datatype import jsonToAvroType, jsonNodeToAvroType, checkData, Type, avroTypeToAvroSchema
from ..utils import compare_items
from ..codec import to_json, from_json, recordset_from_json
import types
import time
from six.moves import zip_longest # izip_longest renamed

import re

class PyModel(Model):

    def __init__(self, name=None, mtype='python', source=None, model_manage=None, schemas={}, action=None,
         options={}, begin=None, end=None, functions=[], imports=[]):
        """
        A Python Model's constructor.

        Required fields:
        - name: A name for the model.
        - schemas: The input and output schemas for the model.

        Optional fields:
        - source: The source code for this model. If specified, then the rest of
          the fields are ignored.

        - action: The action method for this model (if not source)
        - options: options specified by "fastscore.*: " smart comments. (if not source)
        - begin, end: begin and end functions for the model (if not source)
        - functions: a list of other user-defined functions needed to execute
                     action, begin, or end (if not source)
        - imports: a list of import statements made by the model (as strings) (if not source)
        """
        super(PyModel, self).__init__(name=name, mtype=mtype, source=source,
                                      model_manage=model_manage,
                                      schemas=schemas)
        if name:
            self.name = name
        else:
            self.name = 'model_' + str(int(time.time()))
        if source:
            self.source = source
        else:
            self.action = action
            self.begin = begin
            self.end = end
            self.functions = functions
            self.options = options
            self.imports = imports

    @property
    def source(self):
        """
        The source code of this model.
        """
        return self.to_string()

    @source.setter
    def source(self, source):
        self._source = source
        # self = PyModel.from_string(source)

    def to_string(self):
        """
        Convert this model object to a string, ready for use in FastScore.
        """

        output_str = '# fastscore.input: '  + self.schemas['input'].name  + '\n' + \
                     '# fastscore.output: ' + self.schemas['output'].name + '\n'

        for option in self.options:
            if option != 'input' and option != 'output':
                output_str += '# fastscore.' + option + ': ' + self.options[option] + '\n'
        output_str += '\n'
        for statement in self.imports:
            output_str += statement + '\n'
        try:
            output_str += '\n' + getsource(self.action) + '\n\n'
        except IOError:
            try:
                output_str += '\n' + self.action.source + '\n\n'
            except AttributeError:
                raise AttributeError('Could not find source for action function.')
        if self.begin:
            try:
                output_str += getsource(self.begin) + '\n\n'
            except IOError:
                try:
                    output_str += self.begin.source + '\n\n'
                except AttributeError:
                    raise AttributeError('Could not find source for begin function.')
        if self.end:
            try:
                output_str += getsource(self.end) + '\n\n'
            except IOError:
                try:
                    output_str += self.end.source + '\n\n'
                except AttributeError:
                    raise AttributeError('Could not find source for end function.')

        for fcn in self.functions:
            try:
                output_str += getsource(fcn) + '\n\n'
            except IOError:
                try:
                    output_str += fcn.source + '\n\n'
                except AttributeError:
                    raise AttributeError('Could not find source for function: ' + fcn.__name__)
        return output_str.encode('utf-8')

    def score(self, inputs, complete=True, use_json=False):
        """
        Scores data using this model.

        Required fields:
        - inputs: The input data. This can be either a single item, or an
                  iteratable collection of items (e.g. a list)

        Optional fields:
        - complete: A boolean. If True, execute 'begin()' at the start and
                    'end()' at the end (default). If False, skip executing
                    'begin()' and 'end()'
        - use_json: If True, inputs and outputs are JSON strings. Default: False.
        """
        if complete and self.begin:
            self.begin()

        iterable = isinstance(inputs, collections.Iterable) \
                   and not isinstance(inputs, str)   \
                   and not isinstance(inputs, dict) # a dict is a record in our world

        recordset_input = False
        recordset_output = False
        if 'recordsets' in self.options:
            if self.options['recordsets'] == 'input':
                recordset_input = True
            elif self.options['recordsets'] == 'output':
                recordset_output = True
            elif self.options['recordsets'] == 'both':
                recordset_input = True
                recordset_output = True

        input_schema = jsonNodeToAvroType(self.schemas['input'].source)
        output_schema = jsonNodeToAvroType(self.schemas['output'].source)
        # now we process the input data, score it with the model, and produce
        # the output
        input_data = [] # the processed input data (potentially deserialized)
        results = []    # the scored intput data
        outputs = []    # the data returned to the user (potentially serialized)
        if recordset_input:
            # use record set as input
            if use_json:
                input_data = recordset_from_json(inputs, input_schema)
            else:
                input_data = inputs.copy() # create a copy, so we don't modify the original
            results = [x for x in self.action(input_data)]
        else:
            # don't use record set as input
            if iterable:
                if use_json:
                    input_data = list(from_json(inputs, input_schema))
                else:
                    input_data = [datum for datum in inputs]
            else:
                # not iteratable input.
                if use_json:
                    input_data = list(from_json([inputs], input_schema))
                else:
                    input_data = [inputs]
            results = [x for in_datum in input_data for x in self.action(in_datum)]

        if recordset_output:
            # the only difference is that each row of the output data frame is
            # serialized.
            if use_json:
                outputs += [y for result in results for y in to_json(result, output_schema)]
            else:
                outputs += [x for x in results]
        else:
            if use_json:
                outputs += [y for y in to_json(results, output_schema)]
            else:
                outputs += [x for x in results]

        if len(outputs) == 1 and (not iterable or recordset_output):
            outputs = outputs[0]

        if complete and self.end:
            self.end()
        return outputs

    def validate(self, inputs, outputs, use_json=False):
        """
        Validates that the model produces the expected outputs from the input
        data, and that input and output data match the schema.

        Required fields:
        - inputs: Input data to be scored.
        - outputs: The expected output of the model associated to the given
                   inputs.

        Optional fields:
        - use_json: True if inputs and outputs are JSON strings. Default: False.
        """

        input_schema = jsonNodeToAvroType(self.schemas['input'].source)
        output_schema = jsonNodeToAvroType(self.schemas['output'].source)

        # step 1: check the input schema
        for datum in inputs:
            try:
                if use_json:
                    checkData(json.loads(datum), input_schema)
                else:
                    checkData(datum, input_schema)
            except TypeError:
                if use_json:
                    print('Invalid Input: Expecting type ' + str(input_schema) \
                          + ', found ' + str(datum))
                else:
                    print('Invalid Input: Expecting type ' + str(input_schema) \
                          + ', found ' + str(datum) + ' (' + str(type(datum)) + ')')
                return False

        # step 2: check the output schema
        for datum in outputs:
            try:
                if use_json:
                    checkData(json.loads(datum), output_schema)
                else:
                    checkData(datum, output_schema)
            except TypeError:
                if use_json:
                    print('Invalid Output: Expecting type ' + str(output_schema) \
                          + ', found ' + str(datum))
                else:
                    print('Invalid Output: Expecting type ' + str(output_schema) \
                          + ', found ' + str(datum) + ' (' + str(type(datum)) + ')')
                return False

        # step 3: run the model on the data
        model_outputs = self.score(inputs, complete=True, use_json=use_json)
        for model_out, exp_out in zip_longest(model_outputs, outputs):
            if model_out == None and exp_out != None or model_out != None and exp_out == None:
                print('Differing number of outputs: ' + str(model_out) + ' != ' + str(exp_out))
                return False
            item1 = json.loads(model_out) if use_json else json.loads(json.dumps(model_out))
            item2 = json.loads(exp_out) if use_json else json.loads(json.dumps(exp_out))
            same = compare_items(item1, item2, 0.01)
            if not same:
                print('Different outputs: ' + str(model_out) + ' != ' + str(exp_out))
                return False

        # all items match schema and expected values
        return True

    class ProgressorGhost(object):
        pass

    def deploy(self, engine, generate_streams = True):
        """
        Deploy this model to an engine.

        :param engine: The Engine instance to use.
        :param generate_streams: If True, automatically generate stream
                                 configurations using the REST transport.
        """
        if generate_streams:

            progress = PyModel.ProgressorGhost()
            progress.value = 0
            try:
                from ipywidgets import IntProgress
                from IPython.display import display
                progress = IntProgress(min=0, max=7)
                display(progress)
            except Exception:
                pass

            self.update()
            progress.value += 1
            for schema_name in self.schemas:
                self.schemas[schema_name].update()
            progress.value += 1
            input_stream_name = self.name + '_in'
            output_stream_name = self.name + '_out'
            input_stream_desc = {
                                  "Transport": {
                                    "Type": "REST"
                                  },
                                  "Envelope": "delimited",
                                  "Encoding": "json",
                                  "Schema": {"$ref": self.options['input']}
                                }
            output_stream_desc = {
                                  "Transport": {
                                    "Type": "REST"
                                  },
                                  "Envelope": "delimited",
                                  "Encoding": "json",
                                  "Schema": {"$ref": self.options['output']}
                                }
            if 'recordsets' in self.options:
                if self.options['recordsets'] == 'input' \
                or self.options['recordsets'] == 'both':
                    input_stream_desc['Batching'] = 'explicit'
                if self.options['recordsets'] == 'output' \
                or self.options['recordsets'] == 'both':
                    output_stream_desc['Batching'] = 'explicit'

            input_stream = Stream(input_stream_name, input_stream_desc,
                                  model_manage = self._mm)
            output_stream = Stream(output_stream_name, output_stream_desc,
                                    model_manage = self._mm)
            input_stream.update()
            progress.value += 1
            output_stream.update()
            progress.value += 1

            engine.outputs[1] = output_stream
            progress.value += 1
            engine.inputs[1] = input_stream
            progress.value += 1
            engine.load_model(self)
            progress.value += 1
        else:
            engine.load_model(self)

    @staticmethod
    def from_string(model_str, outer_namespace=None, model_type=None):
        """
        Creates a PyModel object from a string.

        Required fields:
        - model_str: A string of code defining the model.

        Optional fields:
        - outer_namespace: The namespace to bind the defined functions to.
                           Pass this value if you want to be able to call
                           action() or other methods from your Jupyter NB.
                           Default: None.
        """
        code = compile(model_str, '<string>', 'exec')
        namespace = {}
        exec(code, namespace)

        # step 2: extract the functions and modules
        # and copy definitions to outer namespace
        fcns = []
        modules = []
        for key in namespace:
            if key == '__builtins__':
                continue
            if isinstance(namespace[key], types.FunctionType):
                fcns.append(key)
            if isinstance(namespace[key], types.ModuleType):
                modules.append(key)
            if outer_namespace:
                outer_namespace[key] = namespace[key] # copy def'ns

        # step 3: capture function source code
        defs = re.split(r'\n(?=def)', model_str)
        for line in defs:
            defn = line.strip()
            if defn[0:3] != 'def':
                continue
            fcnname = defn.split('(')[0][4:]
            if fcnname in fcns:
                namespace[fcnname].source = defn # add the source to the function

        # step 4: capture imports and schemata
        lines = model_str.split('\n')
        imports = []
        model_options = {}
        model_input_schema = None
        model_output_schema = None
        for line in lines:
            if 'import' in line:
                imports.append(line.strip())
            option = re.search(r'# *fastscore\.(.*):(.*)', line.strip())
            if option:
                option_name = option.group(1).strip()
                option_value = option.group(2).strip()
                model_options[option_name] = option_value
                if option_name == 'input':
                    if outer_namespace and option_value in outer_namespace:
                        model_input_schema = outer_namespace[option_value]
                if option_name == 'output':
                    if outer_namespace and option_value in outer_namespace:
                        model_output_schema = outer_namespace[option_value]

        # step 5: create model
        model_action = namespace['action']
        model_begin = namespace['begin'] if 'begin' in fcns else None
        model_end = namespace['end'] if 'end' in fcns else None
        model_functions = [namespace[fcn_name] for fcn_name in fcns
                           if fcn_name != 'action' and
                              fcn_name != 'begin' and
                              fcn_name != 'end']
        model_schemas = {
                    'input': Schema(name=model_options['input'], source=model_input_schema),
                    'output': Schema(name=model_options['output'], source=model_output_schema)}
        if model_type:
            return model_type(name=None,
                         schemas=model_schemas,
                         action=model_action,
                         options=model_options,
                         begin=model_begin, end=model_end,
                         functions=model_functions, imports=imports)
        else:
            return PyModel(name=None,
                         schemas=model_schemas,
                         action=model_action,
                         options=model_options,
                         begin=model_begin, end=model_end,
                         functions=model_functions, imports=imports)
