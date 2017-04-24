## -- Engine class -- ##
import json
import api
import time
from titus.datatype import avroTypeToSchema, checkData
from codec import to_json, recordset_from_json

class Engine(object):
    def __init__(self, proxy_prefix, model=None, container=None):
        """
        Constructor for the Engine class.

        Required fields:
        - proxy_prefix: URL for the FastScore proxy, e.g., 'https://localhost:8000'

        Optional fields:
        - model: A Model object to load into the engine upon startup.
        - container: The engine container to use. If unspecified, the first
                     available engine is used.
        """
        api.connect(proxy_prefix)
        self.model = model
        self.container = container

    def deploy(self, model):
        """
        Deploy a model to the engine.

        Required fields:
        - model: The model object to deploy.
        """
        api.stop_job(self.container)
        self.model = model
        api.add_model(model.name, model.to_string(), model_type='python2')
        api.add_schema(model.options['input'], model.input_schema.toJson())
        api.add_schema(model.options['output'], model.output_schema.toJson())

        input_stream_name = model.name + '_in'
        output_stream_name = model.name + '_out'
        input_stream_desc = {
                              "Transport": {
                                "Type": "REST"
                              },
                              "Envelope": "delimited",
                              "Encoding": "json",
                              "Schema": {"$ref": model.options['input']}
                            }
        output_stream_desc = {
                              "Transport": {
                                "Type": "REST"
                              },
                              "Envelope": "delimited",
                              "Encoding": "json",
                              "Schema": {"$ref": model.options['output']}
                            }

        if 'recordsets' in model.options:
            if model.options['recordsets'] == 'input' \
            or model.options['recordsets'] == 'both':
                input_stream_desc['Batching'] = 'explicit'
            if model.options['recordsets'] == 'output' \
            or model.options['recordsets'] == 'both':
                output_stream_desc['Batching'] = 'explicit'

        api.add_stream(input_stream_name, json.dumps(input_stream_desc))
        api.add_stream(output_stream_name, json.dumps(output_stream_desc))
        # now, run the model
        api.run_job(model.name, input_stream_name, output_stream_name, self.container)

    def stop(self):
        """
        Stop all running jobs on the engine.
        """
        print 'Engine stopped.'
        api.stop_job(self.container)

    def score(self, data, use_json=False):
        """
        Scores each datum passed in data.

        Required fields:
        - data: a list of data to score.

        Optional fields:
        - use_json: If True, each datum in data is expected to be a JSON string.
                    (Default: False)
        """
        input_list = []
        inputs = []
        if use_json:
            inputs = [x for x in data]
        else:
            input_schema = self.model.input_schema
            inputs = [x for x in to_json(data, input_schema)]
            if 'recordsets' in self.model.options:
                # automatically add a {"$fastscore":"set"} message to the end
                if self.model.options['recordsets'] == 'input' or \
                   self.model.options['recordsets'] == 'both':
                    inputs += ['{"$fastscore":"set"}']

        for datum in inputs:
            input_list += [datum.strip()]
        outputs = api.job_input(input_list, self.container)
        if use_json:
            return outputs
        else:
            if json.loads(outputs[-1]) == {"$fastscore": "set"}:
                outputs = outputs[:-1]
            if 'recordsets' in self.model.options and \
            (self.model.options['recordsets'] == 'output' or \
             self.model.options['recordsets'] == 'both'):
                return recordset_from_json(outputs, self.model.output_schema)
            else:
                return [checkData(json.loads(output), self.model.output_schema) for output in outputs]
