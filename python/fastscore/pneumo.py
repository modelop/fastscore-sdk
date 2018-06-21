
import json
from iso8601 import parse_date
from websocket import create_connection, WebSocketTimeoutException
from ssl import CERT_NONE
import six
if six.PY2:
    from urllib import urlencode
else:
    from urllib.parse import urlencode

from fastscore.utils import format_record

from .errors import FastScoreError

PNEUMO_WS_PATH = '/api/1/service/connect/2/pneumo'

class PneumoSock(object):
    """
    The Pneumo websocket.

    >>> pneumo = connect.pneumo()
    >>> pneumo.recv()
    LogMsg(src=..., timestamp=..., ...)

    """

    def __init__(self, proxy_prefix, timeout=None, src=None, type=None, basicauth_secret=None, **kwargs):
        url = proxy_prefix.replace('https:', 'wss:') + PNEUMO_WS_PATH
        params = {}
        if src != None:
            params['src'] = src
        if type != None:
            params['type'] = type
        if len(params) > 0:
            url += "?" + urlencode(params)
        if basicauth_secret == None:
            self._ws = create_connection(url, sslopt = {'cert_reqs': CERT_NONE})
        else:
            self._ws = create_connection(url, header=["Authorization: " + basicauth_secret], sslopt = {'cert_reqs': CERT_NONE})
        if timeout != None:
            self._ws.settimeout(timeout)

    def recv(self):
        """
        Receives the next Pneumo message.

        """
        return PneumoSock.makemsg(json.loads(self._ws.recv()))

    def close(self):
        """
        Close the Pneumo socket.
        """
        self._ws.close()

    @staticmethod
    def makemsg(data):
        src = data['src']
        timestamp = data['timestamp']
        ptype = data['type']
        if ptype == 'health':
            return HealthMsg(src, timestamp, data['instance'], data['health'])
        elif ptype == 'log':
            return LogMsg(src, timestamp, data['level'], data['text'])
        elif ptype == 'model-console':
            return ModelConsoleMsg(src, timestamp, data['text'])
        elif ptype == 'engine-state':
            return EngineStateMsg(src, timestamp, data['state'])
        elif ptype == 'engine-config':
            return EngineConfigMsg(src, timestamp, data['item'], data['op'], data.get('ref'))
        elif ptype == 'sensor-report':
            delta_time = data['delta_time'] if 'delta_time' in data else None
            return SensorReportMsg(src,
                                   timestamp,
                                   data['id'],
                                   data['tap'],
                                   data['data'],
                                   delta_time)
        elif ptype == 'model-error':
            return ModelErrorMsg(src, timestamp, data['input'], data['console'])
        else:
            raise FastScoreError("Unexpected Pneumo message type '%s'" % ptype)

# After Swagger starts to support anyOf schemas we can replace classes below
# with ones autogenerated by Swagger under fastscore.v2.models. Maybe not.

class PneumoMsg(object):
    def __init__(self, src, timestamp):
        self._src = src
        self._timestamp = parse_date(timestamp)

    @property
    def src(self):
        return self._src

    @property
    def timestamp(self):
        return self._timestamp

    def __str__(self):
        when = self._timestamp.strftime("%X.%f")[:-3]
        return "{}:{}".format(when, self._src)

    def __repr__(self):
        return "PneumoMsg(src=%s, timestamp=%s)" % (self.src,self.timestamp)

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

    def __str__(self):
        if self._health == 'ok':
            updown = "up"
        elif self._health == 'fail':
            updown = "DOWN"
        else:
            updown = self._health

        return "{}: {} is {}".format(super(HealthMsg, self).__str__(), self._instance, updown)

    def __repr__(self):
        return "HealthMsg(src=%s, timestamp=%s, instance=%s, health=%s)" \
                    % (self.src,self.timestamp,self.instance,self.health)

class LogMsg(PneumoMsg):

    LAGER_LEVELS = {
        128: 'debug',
        64: 'info',
        32: 'notice',
        16: 'warning',
        8: 'error',
        4: 'critical',
        2: 'alert',
        1: 'emergency',
    }

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

    def __str__(self):
        severity = LogMsg.LAGER_LEVELS[self._level] \
                    if self._level in LogMsg.LAGER_LEVELS else self._level
        return "{}: log[{}] {}".format(super(LogMsg, self).__str__(), severity, self._text)

    def __repr__(self):
        return "LogMsg(src=%s, timestamp=%s, level=%s, text=%s)" \
                    % (self.src,self.timestamp,self.level,self.text.replace('\n', '\\n'))

class ModelConsoleMsg(PneumoMsg):
    def __init__(self, src, timestamp, text):
        super(ModelConsoleMsg, self).__init__(src, timestamp)
        self._text = text

    @property
    def text(self):
        return self._text

    def __str__(self):

        # 20/20/2017:engine-1> Model loaded
        #                      Input is set
        #                      Output is set

        prefix = "{}> ".format(super(ModelConsoleMsg, self).__str__())
        ll = self._text.rstrip().split("\n")
        s = prefix + ll[0]
        for l in ll[1:]:
            s += "\n" + " " * len(prefix) + l
        return s

    def __repr__(self):
        return "ModelConsoleMsg(src=%s, timestamp=%s, text=%s)" \
                    % (self.src,self.timestamp,self.text.replace('\n', '\\n'))

class EngineStateMsg(PneumoMsg):
    def __init__(self, src, timestamp, state):
        super(EngineStateMsg, self).__init__(src, timestamp)
        self._state = state

    @property
    def state(self):
        return self._state

    def __str__(self):
        return "{}: state is {}".format(super(EngineStateMsg, self).__str__(), self._state.upper())

    def __repr__(self):
        return "EngineState(src=%s, timestamp=%s, state=%s)" \
                    % (self.src,self.timestamp,self.state.upper())

class EngineConfigMsg(PneumoMsg):
    def __init__(self, src, timestamp, item, op, ref=None):
        super(EngineConfigMsg, self).__init__(src, timestamp)
        self._item = item
        self._op   = op
        self._ref = ref

    @property
    def item(self):
        return self._item

    @property
    def op(self):
        return self._op

    @property
    def ref(self):
        return self._ref

    def __str__(self):
        if self._item == 'model':
            if self._op == 'load':
                s = "model loaded"
            elif self._op == 'reload':
                s = "model reloaded"
            elif self._op == 'unload':
                s = "model unloaded"
        elif self._item == 'stream':
            if self._op == 'attach':
                s = "stream attached to {}".format(self._ref)
            elif self._op == 'reattach':
                s = "stream reattached to {}".format(self._ref)
            elif self._op == 'detach':
                s = "stream detached from {}".format(self._ref)
        elif self._item == 'jet':
            if self._op == 'start':
                s = "jet started ({})".format(self._ref)
            elif self._op == 'stop':
                s = "jet stoppped ({})".format(self._ref)
        else:
            s = repr(self)
        return "{}: {}".format(super(EngineConfigMsg, self).__str__(), s)

    def __repr__(self):
        return "EngineConfig(src=%s, timestamp=%s, item=%s, op=%s, ref=%s)" \
                    % (self.src,self.timestamp,self.item,self.op,self.ref)

class SensorReportMsg(PneumoMsg):
    def __init__(self, src, timestamp, sid, point, data, delta_time):
        super(SensorReportMsg, self).__init__(src, timestamp)
        self._sid   = sid
        self._point = point
        self._data  = data
        self._delta_time = delta_time

    @property
    def sid(self):
        return self._sid

    @property
    def point(self):
        return self._point

    @property
    def data(self):
        return self._data

    @property
    def delta_time(self):
        return self._delta_time

    def __str__(self):
        return "{}: sensor[{}] {}: {}".format(super(SensorReportMsg, self).__str__(), \
                        self.sid, self.point, repr(self.data))

    def __repr__(self):
        return "SensorReportMsg(src=%s, timestamp=%s, sid=%d, point=%s, data=%s, delta_time=%f)" \
                    % (self.src,self.timestamp,self.sid,self.point,repr(self.data),self.delta_time)

class ModelInputInfo():
    def __init__(self, slot, seqno, data, batch_len, encoding):
        self._slot = slot
        self._seqno = seqno
        self._data = data
        self._batch_len = batch_len
        self._encoding = encoding

    @property
    def slot(self):
        return self._slot

    @property
    def seqno(self):
        return self._seqno

    @property
    def data(self):
        return self._data

    @property
    def batch_len(self):
        return self._batch_len

    @property
    def encoding(self):
        return self._encoding

    @property
    def slot(self):
        return self._slot

class ModelErrorMsg(PneumoMsg):
    def __init__(self, src, timestamp, last, console):
        super(ModelErrorMsg, self).__init__(src, timestamp)
        self._input = ModelInputInfo(last['slot'],
                                     last['seqno'],
                                     last['data'],
                                     last['batch_len'],
                                     last['encoding']) if last else None
        self._console = console

    @property
    def input(self):
        return self._input

    @property
    def console(self):
        return self._console

    def __str__(self):

        # 20/20/2017:engine-1: MODEL ERROR
        #                      The input that caused the error:
        #                          99: {"a": 1}
        #                         100: {"a": 2}
        #                      (180 record(s) skipped)
        #                      -------------------------------
        #                      Traceback (most recent call last):
        #                        File "__model.py", line 5, in <module>
        #                      ...

        prefix = "{}: ".format(super(ModelErrorMsg, self).__str__())
        indent = " " * len(prefix)
        s = "{}MODEL ERROR".format(prefix)
        if not self._input:
            s += "\n" + indent + "(last input not available)"
        else:
            s += "\n" + indent + "The input that caused the error:"
            for i,x in enumerate(self._input.data, self._input.seqno):
                s += "\n" + indent + format_record(x, i)
            if self._input.batch_len > len(self.input._data):
                skipped = self._input.batch_len - len(self.input._data)
                s += "\n" + indent + "({} record(s) skipped)".format(skipped)
            s += "\n" + indent + "-" * 32
        for l in self._console.rstrip().split("\n"):
            s += "\n" + indent + l
        return s

    def __repr__(self):
        return "ModelErrorMsg(src={}, timestamp={}, input={}, console={})"\
                    .format(self.src, self.input, self.console.rstrip().replace('\n', '\\n'))

