
import json
from iso8601 import parse_date
from websocket import create_connection, WebSocketTimeoutException
from ssl import CERT_NONE

PNEUMO_WS_PATH = '/api/1/service/connect/1/notify'

class PneumoSock(object):
    def __init__(self, proxy_prefix):
        url = proxy_prefix.replace('https:', 'wss:') + PNEUMO_WS_PATH
        self._ws = create_connection(url, sslopt = {'cert_reqs': CERT_NONE})

    def recv(self):
        return PneumoSock.make_message(json.loads(self._ws.recv()))

    def close(self):
        self._ws.close()

    @staticmethod
    def make_message(data):
        src = data['src']
        timestamp = data['timestamp']
        ptype = data['type']
        if ptype == 'health':
            return HealthMsg(src, timestamp, data['instance'], data['health'])
        elif ptype == 'log':
            return LogMsg(src, timestamp, data['level'], data['text'])
        elif ptype == 'model-console':
            return ModelConsoleMsg(src, timestamp, data['text'])
        elif ptype == 'output-eof':
            return OutputEOFMsg(src, timestamp, data['last'])
        elif ptype == 'sensor-report':
            return SensorReportMsg(src, timestamp, data['id'], data['tap'], data['data'])
        elif ptype == 'jet-status-report':
            return JetStatusReportMsg(src, timestamp, data['jets'])
        else:
            raise FastScoreError("Unexpected Pneumo message type '%s'" % ptype)

class PneumoMsg(object):
    def __init__(self, src, timestamp):
        self._src = src
        self._timestamp = parse_date(timestamp)

class HealthMsg(PneumoMsg):
    def __init__(self, src, timestamp, instance, health):
        super(HealthMsg, self).__init__(src, timestamp)
        self._instance = instance
        self._health = health

    @property
    def instance(self):
        return self._instance

    @property
    def health(self):
        return self._health

class LogMsg(PneumoMsg):
    def __init__(self, src, timestamp, level, text):
        super(LogMsg, self).__init__(src, timestamp)
        self._level = level
        self._text = text

    @property
    def level(self):
        return self._level

    @property
    def text(self):
        return self._text

class ModelConsoleMsg(PneumoMsg):
    def __init__(self, src, timestamp, text):
        super(ModelConsoleMsg, self).__init__(src, timestamp)
        self._text = text

    @property
    def text(self):
        return self._text

class OutputEOFMsg(PneumoMsg):
    def __init__(self, src, timestamp, last):
        super(OutputEOFMsg, self).__init__(src, timestamp)
        self._last = last

    @property
    def last(self):
        return self._last

class SensorReportMsg(PneumoMsg):
    def __init__(self, src, timestamp, tapid, point, data):
        super(SensorReportMsg, self).__init__(src, timestamp)
        self._tapid = tapid
        self._point = point
        self._data = data

    @property
    def tapid(self):
        return self._tapid

    @property
    def point(self):
        return self._point

    @property
    def data(self):
        return self._data

class JetStatusReportMsg(PneumoMsg):
    def __init__(self, src, timestamp, jets):
        super(JetStatusReportMsg, self).__init__(src, timestamp)
        self._jets = jets

    @property
    def jets(self):
        return self._jets

