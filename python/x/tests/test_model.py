
from fastscore import Model

from fastscore.suite import Connect

from fastscore import FastScoreError

from unittest import TestCase
from mock import patch

class ModelTests(TestCase):

    PY2 = 'application/vnd.fastscore.model-python'

    class ServiceInfo(object):
        def __init__(self, name):
            self.api = 'model-manage'
            self.name = name
            self.health = 'ok'

    @patch('fastscore.suite.connect.ConnectApi.connect_get',
                return_value=[ServiceInfo('mm-1')])
    @patch('fastscore.suite.model_manage.ModelManageApi.model_get_with_http_info',
                return_value=('foo',200,{'content-type':PY2}))
    def setUp(self, model_get, connect_get):
        connect = Connect('https://localhost:8000')
        self.mm = connect.get('mm-1')

    def test_mtype(self):
        model = Model('m1')
        def set_type():
            model.mtype = '%$garbage'
        self.assertRaises(FastScoreError, set_type)
    
    @patch('fastscore.suite.connect.ConnectApi.connect_get',
                return_value=[ServiceInfo('mm-1')])
    @patch('fastscore.suite.model_manage.ModelManageApi.model_get_with_http_info',
                return_value=('foo',200,{'content-type':PY2}))
    @patch('fastscore.suite.model_manage.ModelManageApi.model_put_with_http_info',
                return_value=('dummy',204,'dummy'))
    def test_update1(self, model_put, model_get, connect_get):
        connect = Connect('https://localhost:8000')
        mm = connect.get('mm-1')
        model = mm.models['m1']
        model.source = 'bar'
        model.update()
        model_put.assert_called_once_with('mm-1', 'm1', 'bar', content_type=ModelTests.PY2)

    # attachments
    # snapshots

