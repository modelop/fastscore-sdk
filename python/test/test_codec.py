from unittest import TestCase
from mock import patch

import pandas as pd
import numpy as np
import json

from fastscore.codec.datatype import jsonNodeToAvroType
from fastscore.codec import to_json, from_json, recordset_to_json, recordset_from_json

class CodecTests(TestCase):

    def test_to_json(self):

        def check_outputs(in_data, out_data, schema):
            outputs = [x for x in to_json(in_data, schema)]
            for i in range(0, len(out_data)):
                self.assertEqual(out_data[i], json.loads(outputs[i]))


        int_sch1 = jsonNodeToAvroType({'type':'int'})
        int_sch2 = jsonNodeToAvroType('int')
        int_inputs = [1, 2, 3, 4, 5]
        check_outputs(int_inputs, int_inputs, int_sch1)
        check_outputs(int_inputs, int_inputs, int_sch2)

        float_sch = jsonNodeToAvroType({'type':'float'})
        float_inputs = [1.0, 2.0, 3.0, 4.0]
        check_outputs(float_inputs, float_inputs, float_sch)

        string_sch1 = jsonNodeToAvroType('string')
        string_sch2 = jsonNodeToAvroType({'type':'string'})
        string_inputs = ['a', 'b', 'c', 'def']
        check_outputs(string_inputs, string_inputs, string_sch1)
        check_outputs(string_inputs, string_inputs, string_sch2)

        union_sch1 = jsonNodeToAvroType(['string', 'int'])
        union_inputs = [1, 'abc', 3]
        union_expected_outs = [{'int':1}, {'string':'abc'}, {'int':3}]
        check_outputs(union_inputs, union_expected_outs, union_sch1)

        union_sch2 = jsonNodeToAvroType([{'type':'string'}, 'int'])
        check_outputs(union_inputs, union_expected_outs, union_sch2)

        record_sch = jsonNodeToAvroType({
            'type':'record',
            'name':'xy',
            'fields':[
                {'name':'x', 'type':'int'},
                {'name':'y', 'type':'string'}
            ]})
        record_inputs = [{'x':1, 'y':'abc'}, {'x':3, 'y':'def'}]
        check_outputs(record_inputs, record_inputs, record_sch)

        # --- record sets
        df_schema = jsonNodeToAvroType(
            {
                'type':'record',
                'name':'xy',
                'fields':[
                    {'name':'x', 'type':'double'},
                    {'name':'y', 'type':'double'}
                ]
            }
        )
        mydf = pd.DataFrame({'x':[1.0, 2.0, 3.0], 'y':[4.0, 5.0, 6.0]})
        df_exp_outs = [{'x':1.0, 'y':4.0}, {'x':2.0, 'y':5.0}, {'x':3.0, 'y':6.0}]
        check_outputs(mydf, df_exp_outs, df_schema)

        array_sch = jsonNodeToAvroType({'type':'array', 'items':'double'})
        npmat = np.matrix([[1, 2, 3],[4, 5, 6]])
        array_exp_outs = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]
        check_outputs(npmat, array_exp_outs, array_sch)

    def test_from_json(self):

        def check_outputs(inputs, outputs, schema):
            output_data = [x for x in from_json(inputs, schema)]
            for i in range(0, len(outputs)):
                self.assertEqual(outputs[i], output_data[i])

        int_sch = jsonNodeToAvroType('int')
        int_outputs = [1, 2, 3, 4]
        int_inputs = ['1', '2', '3', '4']
        check_outputs(int_inputs, int_outputs, int_sch)

        int_sch_2 = jsonNodeToAvroType(['int', 'string'])
        int_inputs_2 = ['{"int":1}','{"int":2}','{"int":3}','{"int":4}']
        check_outputs(int_inputs_2, int_outputs, int_sch_2)

        union_sch1 = jsonNodeToAvroType(['string', 'int'])
        union_outputs = [1, 'abc', 3]
        union_inputs = ['{"int":1}', '{"string":"abc"}', '{"int":3}']
        check_outputs(union_inputs, union_outputs, union_sch1)

        union_sch2 = jsonNodeToAvroType([{'type':'string'}, 'int'])
        check_outputs(union_inputs, union_outputs, union_sch2)

        record_sch = jsonNodeToAvroType({
            'type':'record',
            'name':'xy',
            'fields':[
                {'name':'x', 'type':'int'},
                {'name':'y', 'type':'string'}
            ]})
        record_inputs = ['{"x":1, "y":"abc"}', '{"x":3, "y":"def"}']
        record_outputs = [{'x':1, 'y':'abc'}, {'x':3, 'y':'def'}]
        check_outputs(record_inputs, record_outputs, record_sch)

        pass

    def test_recordset_from_json(self):
        pass

    def test_recordset_to_json(self):
        pass
