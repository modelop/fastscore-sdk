#!/usr/bin/env python

from fastscore.suite import Connect

co = Connect('https://localhost:8000')

mm = co.lookup('model-manage')

print mm.sensors.names()
print mm.streams.names()

