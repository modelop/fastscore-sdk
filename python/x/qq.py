#!/usr/bin/env python

from fastscore.suite import Connect

co = Connect('https://localhost:8000')

en = co.lookup('engine')
en.swg.model_load('engine-1', 'my-model-source', att1='my-att-1')

#print mm.sensors.names()
#print mm.streams.names()

