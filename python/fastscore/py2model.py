## -- Model class -- ##
from inspect import getsource
import json
import collections
from titus.datatype import jsonToAvroType, checkData, Type, avroTypeToSchema
from itertools import izip_longest
from utils import compare_items
from codec import to_json, from_json, recordset_from_json
import types
import time
from model import Model

import re

class Py2Model(Model):

    def __init__(self, action, input_schema, output_schema, options={}, begin=None, end=None, functions=[],
                 attachments=[], imports=[], name=None):
        """
        A Python2 Model's constructor.

        Required fields:
        - action: a function
        - input_schema: an input schema to use (titus.datatype.AvroType or JSON string)
        - output_schema: an output schema to use (titus.datatype.AvroType or JSON string)

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
        super(Py2Model, self).__init__(input_schema=input_schema,
                                       output_schema=output_schema,
                                       attachments=attachments)
        self.action = action
        self.begin = begin
        self.end = end
        self.functions = functions
        self.options = options
        self.imports = imports
        self.model_type = 'python2'

    def to_string(self):
        """
        Convert this model object to a string, ready for use in FastScore.
        """

        output_str = '# fastscore.input: '  + self.options['input']  + '\n' + \
                     '# fastscore.output: ' + self.options['output'] + '\n'

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
        return output_str

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
                   and not isinstance(inputs, basestring)   \
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

        # now we process the input data, score it with the model, and produce
        # the output
        input_data = [] # the processed input data (potentially deserialized)
        results = []    # the scored intput data
        outputs = []    # the data returned to the user (potentially serialized)
        if recordset_input:
            # use record set as input
            if use_json:
                input_data = recordset_from_json(inputs, self.input_schema)
            else:
                input_data = inputs.copy() # create a copy, so we don't modify the original
            results = [x for x in self.action(input_data)]
        else:
            # don't use record set as input
            if iterable:
                if use_json:
                    input_data = list(from_json(inputs, self.input_schema))
                else:
                    input_data = [datum for datum in inputs]
            else:
                # not iteratable input.
                if use_json:
                    input_data = list(from_json([inputs], self.input_schema))
                else:
                    input_data = [inputs]
            results = [x for in_datum in input_data for x in self.action(in_datum)]

        if recordset_output:
            # the only difference is that each row of the output data frame is
            # serialized.
            if use_json:
                outputs += [y for result in results for y in to_json(result, self.output_schema)]
            else:
                outputs += [x for x in results]
        else:
            if use_json:
                outputs += [y for y in to_json(results, self.output_schema)]
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
        # step 1: check the input schema
        for datum in inputs:
            try:
                if use_json:
                    checkData(json.loads(datum), self.input_schema)
                else:
                    checkData(datum, self.input_schema)
            except TypeError:
                if use_json:
                    print 'Invalid Input: Expecting type ' + str(self.input_schema) \
                          + ', found ' + str(datum)
                else:
                    print 'Invalid Input: Expecting type ' + str(self.input_schema) \
                          + ', found ' + str(datum) + ' (' + str(type(datum)) + ')'
                return False

        # step 2: check the output schema
        for datum in outputs:
            try:
                if use_json:
                    checkData(json.loads(datum), self.output_schema)
                else:
                    checkData(datum, self.output_schema)
            except TypeError:
                if use_json:
                    print 'Invalid Output: Expecting type ' + str(self.output_schema) \
                          + ', found ' + str(datum)
                else:
                    print 'Invalid Output: Expecting type ' + str(self.output_schema) \
                          + ', found ' + str(datum) + ' (' + str(type(datum)) + ')'
                return False

        # step 3: run the model on the data
        model_outputs = self.score(inputs, complete=True, use_json=use_json)
        for model_out, exp_out in izip_longest(model_outputs, outputs):
            if model_out == None and exp_out != None or model_out != None and exp_out == None:
                print 'Differing number of outputs: ' + str(model_out) + ' != ' + str(exp_out)
                return False
            item1 = json.loads(model_out) if use_json else json.loads(json.dumps(model_out))
            item2 = json.loads(exp_out) if use_json else json.loads(json.dumps(exp_out))
            same = compare_items(item1, item2, 0.01)
            if not same:
                print 'Different outputs: ' + str(model_out) + ' != ' + str(exp_out)
                return False

        # all items match schema and expected values
        return True

    @staticmethod
    def from_string(model_str, outer_namespace=None):
        """
        Creates a Py2Model object from a string.

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

        return Py2Model(action=model_action,
                     input_schema=model_input_schema,
                     output_schema=model_output_schema,
                     options=model_options,
                     begin=model_begin, end=model_end,
                     functions=model_functions, imports=imports)
