
from fastscore.suite import Connect

from fastscore import FastScoreError

from unittest import TestCase
from mock import patch

from os.path import exists
from os import remove

class ConnectTests(TestCase):

    @patch('fastscore.suite.connect.ConnectApi.health_get')
    def test_check_health(self, health_get):
        connect = Connect('https://dashboard:8000')
        connect.check_health()
        health_get.assert_called_once_with('connect')

    @patch('fastscore.suite.connect.ConnectApi.swagger_get')
    def test_get_swagger(self, swagger_get):
        connect = Connect('https://dashboard:8000')
        connect.get_swagger()
        swagger_get.assert_called_once_with('connect')
    
    def test_connect(self):
        self.assertRaises(FastScoreError, lambda : Connect('foobar'))
        self.assertRaises(FastScoreError, lambda : Connect('http://dashboard'))
        connect = Connect('https://dashboard:8000')

    @patch('fastscore.suite.connect.ConnectApi.config_put_with_http_info',
                return_value=(None,204,None))
    def test_configure(self, config_put):
        connect = Connect('https://dashboard:8000')
        self.assertRaises(FastScoreError, lambda : connect.configure('fastscore:\n'))
        self.assertRaises(FastScoreError, lambda : connect.configure([]))
        connect.configure({'fastscore': []})
        self.assertTrue(config_put.called)

    @patch('fastscore.suite.connect.ConnectApi.config_get',
                return_value='fastscore:\n')
    def test_get_config(self, config_get):
        connect = Connect('https://dashboard:8000')
        self.assertRaises(FastScoreError, lambda : connect.get_config(3.14))
        connect.get_config()
        config_get.assert_called_with('connect', accept='application/x-yaml')
        connect.get_config('db')
        config_get.assert_called_with('connect', q='db', accept='application/x-yaml')

    def test_save(self):
        savefile = '/tmp/__fastscore_test__'
        if exists(savefile):
            remove(savefile)
        connect = Connect('https://dashboard:8000')
        self.assertRaises(FastScoreError, lambda : connect.dump('/'))
        connect.dump(savefile)
        self.assertTrue(exists(savefile))
        Connect.load(savefile)

    class HealthInfo(object):
        def __init__(self, name, health='ok'):
            self.api = 'model-manage'
            self.name = name
            self.health = health

    @patch('fastscore.suite.connect.ConnectApi.connect_get')
    def test_get(self, connect_get):
        connect = Connect('https://dashboard:8000')
        connect_get.return_value = []
        self.assertRaises(FastScoreError, lambda : connect.get('model-manage'))  
        connect_get.return_value = [ConnectTests.HealthInfo('mm-1', health='fail')]
        self.assertRaises(FastScoreError, lambda : connect.get('model-manage'))  
        connect_get.return_value = [ConnectTests.HealthInfo('mm-1')]
        mm = connect.get('model-manage')

    @patch('fastscore.suite.connect.ConnectApi.connect_get',
                return_value=[HealthInfo('mm-1')])
    def test_cache(self, connect_get):
        connect = Connect('https://dashboard:8000')
        mm1 = connect.get('mm-1')
        mm2 = connect.get('mm-1')
        self.assertEqual(mm1, mm2)
        connect_get.assert_called_once_with('connect', name='mm-1')

    @patch('fastscore.suite.connect.ConnectApi.connect_get',
                return_value=[HealthInfo('mm-1'),
                              HealthInfo('mm-2'),
                              HealthInfo('mm-3')])
    def test_lookup(self, connect_get):
        connect = Connect('https://dashboard:8000')
        mm = connect.lookup('model-manage')
        self.assertEqual('mm-1', mm.name)
        connect.prefer('model-manage', 'mm-2')
        mm = connect.lookup('model-manage')
        self.assertEqual('mm-2', mm.name)
        connect.target = connect.get('mm-3')
        mm = connect.lookup('model-manage')
        self.assertEqual('mm-3', mm.name)

    @patch('fastscore.suite.connect.ConnectApi.connect_get',
                return_value=[HealthInfo('mm-1')])
    def test_fleet(self, connect_get):
        connect = Connect('https://dashboard:8000')
        connect.fleet()
        connect_get.assert_called_once_with('connect')

    @patch('fastscore.suite.connect.ConnectApi.active_sensor_list')
    def test_active_sensors(self, sensor_list):
        connect = Connect('https://dashboard:8000')
        connect.active_sensors.ids()
        sensor_list.assert_called_once_with('connect')

    @patch('fastscore.suite.connect.ConnectApi.active_sensor_available')
    def test_tapping_points(self, sensor_available):
        connect = Connect('https://dashboard:8000')
        connect.tapping_points()
        sensor_available.assert_called_once_with('connect')

    #NB: connect.pneumo() not tested

