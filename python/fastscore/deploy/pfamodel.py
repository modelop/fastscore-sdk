from ..model import Model
from ..schema import Schema
import yaml
import json
from titus.genpy import PFAEngine
from titus.prettypfa import jsonNode
from titus.datatype import checkData
import time
import collections
from titus.datatype import jsonToAvroType, checkData, avroTypeToSchema
import fastscore.codec.datatype
from fastscore.utils import compare_items
from fastscore.codec import to_json, from_json
from six.moves import zip_longest # izip_longest renamed

class PFAModel(Model):
    def __init__(self, name=None, mtype='pfa-yaml', pfa, model_manage=None):
        """
        A PFA Model's constructor.

        Required fields:
        - pfa: the content of the PFA model. This may be either a JSON string,
               a YAML string, or a Python dictionary object.

        Optional fields:
        - name: a name for this model.
        """

        self._name = name
        self.mtype = mtype
        self._mm = model_manage


        if type(pfa) is str:
            self.__pfaengine, = PFAEngine.fromYaml(pfa)
        elif type(pfa) is dict:
            self.__pfaengine, = PFAEngine.fromJson(pfa)
        else:
            raise TypeError('PFAModel field is not a PFA document.')

        my_input_schema = _titus_to_fastscore_avrotype(self.__pfaengine.inputType)
        my_output_schema = _titus_to_fastscore_avrotype(self.__pfaengine.outputType)


        model_name = name
        if not name:
            model_name = 'model_' + str(int(time.time()))

        my_schemas = {'input': Schema(name=model_name+'_in', source=repr(my_input_schema), model_manage=model_manage),
                      'output': Schema(name=model_name+'_out', source=repr(my_output_schema), model_manage=model_manage)}

        super(PFAModel, self).__init__(name=model_name, mtype='pfa-yaml',
                        source=pfa, model_manage=model_manage, schemas=my_schemas)

        self.options = {}

    @property
    def source(self):
        """
        The source code of this model.
        """
        return self._source

    @source.setter
    def source(self, source):
        self._source = source
        self.__pfaengine, = PFAEngine.fromYaml(source)

    def to_string(self):
        """
        Convert this model object to a string, ready for use in FastScore.
        """
        return self.__pfaengine.config.toJson()

    def score(self, inputs, complete=True, use_json=False):
        """
        Scores data using this model.

        Required fields:
        - inputs: The input data. This can either be a single item, or an iterable
                  collection of items (e.g. a list)

        Optional fields:
        - complete: A boolean. If True, execute 'begin' at the start of the run
                    and 'end' at the end (default). If False, skip executing
                    these steps.
        - use_json: If True, inputs and outputs are JSON strings. Default: False.
        """
        if complete:
            self.__pfaengine.begin()

        iterable = isinstance(inputs, collections.Iterable) \
                   and not isinstance(inputs, str)   \
                   and not isinstance(inputs, dict) # a dict is a record in our world


        input_schema = jsonNodeToAvroType(self.schemas['input'])
        output_schema = jsonNodeToAvroType(self.schemas['output'])

        input_data = []
        results = []
        outputs = []
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
        # three possible methods for producing output with PFA
        if self.__pfaengine.config.method == 'map':
            results = [self.__pfaengine.action(x) for x in input_data]
        elif self.__pfaengine.config.method == 'emit':
            def emit(x):
                results.append(x)
            self.__pfaengine.emit = emit
            for i in input_data:
                self.__pfaengine.action(i)
        elif self.__pfaengine.config.method == 'fold':
            raise NotImplementedError('TODO: Support fold models.')

        if use_json:
            outputs += [y for y in to_json(results, output_schema)]
        else:
            outputs += [x for x in results]

        if len(outputs) == 1 and not iterable:
            outputs = outputs[0]

        if complete:
            self.__pfaengine.end()
        return outputs

    def validate(self, inputs, outputs, use_json=False):
        """
        Validates that the model produces the expected outputs from the input
        data, and that input and output data match the schema.

        Required fields:
        - inputs: Input data to be scored.
        - outputs: The expected output of the model associated to the given inputs.

        Optional fields:
        - use_json: True if inputs and outputs are JSON strings. Default: False.
        """
        # This is mostly the same as in the Py2Model


        input_schema = jsonNodeToAvroType(self.schemas['input'])
        output_schema = jsonNodeToAvroType(self.schemas['output'])

        # step 1: check the input schema
        for datum in inputs:
            try:
                if use_json:
                    checkData(json.loads(datum), input_schema)
                else:
                    checkData(datum, input_schema)
            except TypeError:
                if use_json:
                    print(('Invalid Input: Expecting type ' + str(input_schema) \
                          + ', found ' + str(datum)))
                else:
                    print(('Invalid Input: Expecting type ' + str(input_schema) \
                          + ', found ' + str(datum) + ' (' + str(type(datum)) + ')'))
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
                    print(('Invalid Output: Expecting type ' + str(output_schema) \
                          + ', found ' + str(datum)))
                else:
                    print(('Invalid Output: Expecting type ' + str(output_schema) \
                          + ', found ' + str(datum) + ' (' + str(type(datum)) + ')'))
                return False

        # step 3: run the model on the data
        model_outputs = self.score(inputs, complete=True, use_json=use_json)
        for model_out, exp_out in zip_longest(model_outputs, outputs):
            if model_out == None and exp_out != None or model_out != None and exp_out == None:
                print(('Differing number of outputs: ' + str(model_out) + ' != ' + str(exp_out)))
                return False
            item1 = json.loads(model_out) if use_json else json.loads(json.dumps(model_out))
            item2 = json.loads(exp_out) if use_json else json.loads(json.dumps(exp_out))
            same = compare_items(item1, item2, 0.01)
            if not same:
                print(('Different outputs: ' + str(model_out) + ' != ' + str(exp_out)))
                return False

        # all items match schema and expected values
        return True

    @staticmethod
    def from_string(model_str):
        """
        Creates a PFAModel object from a string. The string must be a valid PFA
        document (JSON or YAML).

        Required fields:
        - model_str: A string of code defining the model.
        """
        return PFAModel(pfa=model_str)

    @staticmethod
    def from_ppfa(model_str):
        """
        Creates a PFAModel object from a PrettyPFA string. The string must be a
        valid PrettyPFA document.

        Required fields:
        - model_str: A string of code defining the model.
        """
        return PFAModel(pfa=json.dumps(jsonNode(model_str)))

def _titus_to_fastscore_avrotype(dtype):
    """
    Utility function to translate from Titus datatype to FastScore datatype.
    Returns the equivalent fastscore.datatype.AvroType object.

    Required fields:
    - dtype: titus.datatype.AvroType object
    """
    return fastscore.codec.datatype.schemaToAvroType(dtype.schema)
