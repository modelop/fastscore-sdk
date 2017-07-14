import config

from fastscore.suite import Connect
from fastscore import Model
from fastscore.suite import Engine

from fastscore.live import ActiveSensor

from fastscore import FastScoreError

from unittest import TestCase
from mock import patch

class EngineTests(TestCase):

    class ServiceInfo(object):
        def __init__(self, name):
            self.api = 'engine'
            self.name = name
            self.health = 'ok'

    class AttachmentInfo(object):
        def __init__(self, name):
            self.name = name
            self.atype = 'tgz'
            self.datasize = Engine.MAX_INLINE_ATTACHMENT + 1
            self.datafile = None

    class JobStatusInfo(object):

        class ModelInfo(object):
            def __init__(self):
                self.input_schema = {'type':'int'}
                self.output_schema = {'type':'int'}
                self.recordsets = 'None'

        def __init__(self, input_schema='int', output_schema='int', recordsets='None'):
            self.model = self.ModelInfo()
            self.model.input_schema = input_schema
            self.model.output_schema = output_schema
            self.model.recordsets = recordsets

    class StreamInfo(object):
        def __init__(self, name, desc={}):
            self.name = name
            self.desc = desc

    @patch('fastscore.suite.connect.ConnectApi.connect_get',
                return_value=[ServiceInfo('engine-1')])
    def setUp(self, connect_get):
        self.connect = Connect('https://dashboard:1234')
        self.engine = self.connect.get('engine-1')

    @patch('fastscore.suite.engine.EngineApi.health_get')
    def test_check_health(self, health_get):
        self.engine.check_health()
        health_get.assert_called_once_with('engine-1')

    @patch('fastscore.suite.engine.EngineApi.swagger_get')
    def test_get_swagger(self, swagger_get):
        self.engine.get_swagger()
        swagger_get.assert_called_once_with('engine-1')

    @patch('fastscore.suite.engine.EngineApi.active_sensor_list')
    def test_active_sensors(self, sensor_list):
        self.engine.active_sensors.ids()
        sensor_list.assert_called_once_with('engine-1')

    @patch('fastscore.suite.engine.EngineApi.active_sensor_list',
                return_value=[{'id':1,'tap':'dummy'}])
    def test_active_sensors(self, sensor_list):
        for x in self.engine.active_sensors:
            self.assertIsInstance(x, ActiveSensor)
        sensor_list.assert_called_once_with('engine-1')

    @patch('fastscore.suite.engine.EngineApi.active_sensor_available')
    def test_tapping_points(self, sensor_available):
        self.engine.tapping_points()
        sensor_available.assert_called_once_with('engine-1')

    ## ------------------------ Models -----------------------------------------

    @patch('fastscore.suite.engine.EngineApi.model_load')
    def test_load_model_error(self, model_load):
        model1 = Model(name='x', source='y')
        with self.assertRaises(FastScoreError):
            self.engine.load_model(model1)

    @patch('fastscore.model.Model.attachments', return_value=[list()])
    @patch('fastscore.suite.engine.EngineApi.model_load')
    def test_load_model_no_attachments(self, model_load, attachments):
        model1 = Model(name='x', source='y')
        self.engine.load_model(model1)

    # for now, only tests externalized attachments
    @patch('fastscore.model.Model.attachments', return_value=[AttachmentInfo('att-1.tar.gz')])
    @patch('fastscore.suite.engine.EngineApi.model_load')
    def test_load_model_with_attachments(self, model_load, attachments):
        model1 = Model(name='x', source='y')
        self.engine.load_model(model1)

    @patch('fastscore.suite.engine.EngineApi.job_delete')
    def test_unload_model(self, job_delete):
        self.engine.unload_model()
        job_delete.assert_called_once()

    @patch('fastscore.suite.engine.EngineApi.job_scale')
    def test_scale(self, job_scale):
        self.engine.scale(5)
        job_scale.assert_called_once_with('engine-1', 5)

    @patch('fastscore.suite.engine.EngineApi.stream_sample')
    def test_sample_stream(self, stream_sample):
        stream = self.StreamInfo('x', {})
        self.engine.sample_stream(stream, 3)
        stream_sample.assert_called_once_with('engine-1', {}, n=3)

    @patch('fastscore.suite.engine.EngineApi.job_status',
            return_value=JobStatusInfo())
    @patch('fastscore.suite.engine.EngineApi.job_io_input')
    @patch('fastscore.suite.engine.EngineApi.job_io_output',
            return_value='1\n2\n3\n4\n{"$fastscore":"pig"}\n')
    def test_score(self, job_output, job_input, job_status_info):
        data = [1, 2, 3, 4]
        scores = self.engine.score(data)
        self.assertEqual(scores, [1, 2, 3, 4])
        job_output.assert_called_once()
        job_input.assert_called_once_with(instance='engine-1', data='1\n2\n3\n4\n{"$fastscore":"pig"}\n', id=1)
        job_status_info.assert_called_once()
