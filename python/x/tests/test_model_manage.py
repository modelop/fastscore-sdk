
from fastscore.suite import Connect
from fastscore import Model

from fastscore import FastScoreError

from unittest import TestCase
from mock import patch

class ModelManageTests(TestCase):

    class ServiceInfo(object):
        def __init__(self, name):
            self.api = 'model-manage'
            self.name = name
            self.health = 'ok'

    @patch('fastscore.suite.connect.ConnectApi.connect_get',
                return_value=[ServiceInfo('mm-1')])
    def setUp(self, connect_get):
        self.connect = Connect('https://dashboard:8000')
        self.mm = self.connect.get('mm-1')

    @patch('fastscore.suite.model_manage.ModelManageApi.health_get')
    def test_check_health(self, health_get):
        self.mm.check_health()
        health_get.assert_called_once_with('mm-1')

    @patch('fastscore.suite.model_manage.ModelManageApi.swagger_get')
    def test_get_swagger(self, swagger_get):
        self.mm.get_swagger()
        swagger_get.assert_called_once_with('mm-1')

    @patch('fastscore.suite.model_manage.ModelManageApi.active_sensor_list')
    def test_active_sensors(self, sensor_list):
        self.mm.active_sensors.ids()
        sensor_list.assert_called_once_with('mm-1')

    @patch('fastscore.suite.model_manage.ModelManageApi.active_sensor_available')
    def test_tapping_points(self, sensor_available):
        self.mm.tapping_points()
        sensor_available.assert_called_once_with('mm-1')

    ##-- models ----------------------------------------------------------------

    @patch('fastscore.suite.model_manage.ModelManageApi.model_list')
    def test_model_names(self, model_list):
        self.mm.models.names()
        model_list.assert_called_once_with('mm-1')

    @patch('fastscore.suite.model_manage.ModelManageApi.model_list')
    def test_iter_models(self, model_list):

        ##TODO
        ##TODO
        ##TODO

        list(self.mm.models)
        model_list.assert_called_once_with('mm-1')

    @patch('fastscore.suite.model_manage.ModelManageApi.model_get_with_http_info',
                return_value=('foo',200,{'content-type':'application/vnd.fastscore.model-python'}))
    def test_get_model(self, model_get):
        model = self.mm.models['m1']
        self.assertIsInstance(model, Model)
        model_get.assert_called_once_with('mm-1', 'm1')

