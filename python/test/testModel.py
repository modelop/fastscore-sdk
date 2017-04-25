import unittest
from fastscore import Model
import pandas as pd

class TestModel(unittest.TestCase):
    def test_from_string(self):
        # Test the creation of models
        # from strings
        model_string = '''
# fastscore.input: int
# fastscore.output: int

def begin():
    global starter
    starter = 3

def action(x):
    global starter
    yield x + starter
'''
        namespace = {'int': '{"type":"int"}'}
        model = Model.from_string(model_string, namespace)
        self.assertEqual(model.score(3), 6)
        self.assertEqual(model.score('3', use_json=True), '6')
    def test_from_string_with_recordsets(self):
        model_string = '''
# fastscore.input: schin
# fastscore.output: schout
# fastscore.recordsets: both

def action(df):
    df['z'] = df['x'] - df['y']
    yield df
'''
        namespace = {
            'schin':'{"type":"record", "name":"in", "fields":[{"type":"int", "name":"x"}, {"type":"int", "name":"y"}]}',
            'schout': '{"type":"record", "name":"out", "fields":[{"type":"int", "name":"x"}, {"type":"int", "name":"y"}, {"type":"int", "name":"z"}]}'
        }
        model = Model.from_string(model_string, namespace)
        mydf = pd.DataFrame({'x':[1, 2, 3], 'y':[1, 2, 3]})
        outdf = pd.DataFrame({'x':[1, 2, 3], 'y':[1, 2, 3], 'z':[0, 0, 0]})
        self.assertEqual(outdf.equals(model.score(mydf)), True)
