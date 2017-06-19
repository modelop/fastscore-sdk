import unittest
import six
if six.PY2:
    from fastscore.deploy import Py2Model
    from fastscore.deploy import PFAModel
elif six.PY3:
    from fastscore.deploy import Py3Model
import pandas as pd

class TestModel(unittest.TestCase):
    def test_py2_from_string(self):
        if six.PY3: # skip if Python3
            return
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
        model = Py2Model.from_string(model_string, namespace)
        self.assertEqual(model.score(3), 6)
        self.assertEqual(model.score('3', use_json=True), '6')
        return

    def test_py2_from_string_with_recordsets(self):
        if six.PY3: # skip if Python3
            return

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
        model = Py2Model.from_string(model_string, namespace)
        mydf = pd.DataFrame({'x':[1, 2, 3], 'y':[1, 2, 3]})
        outdf = pd.DataFrame({'x':[1, 2, 3], 'y':[1, 2, 3], 'z':[0, 0, 0]})
        self.assertEqual(outdf.equals(model.score(mydf)), True)
    def test_pfa_from_string(self):
        if six.PY3:
            return

        model_string = '''
input: int
output: int
action:
  - {m.abs: input}
'''
        model = PFAModel.from_string(model_string)
        self.assertEqual(model.score(3), 3)
        self.assertEqual(model.score(-3), 3)
        self.assertEqual(model.score('3', use_json=True), '3')
    def test_pfa_from_string_emit(self):
        if six.PY3:
            return

        model_string = '''
input: int
output: int
method: emit
action:
  - {emit: {m.abs: input}}
'''
        model = PFAModel.from_string(model_string)
        self.assertEqual(model.score(3), 3)
        self.assertEqual(model.score(-3), 3)
        self.assertEqual(model.score('3', use_json=True), '3')
