# class Model(object):
#   """
# Represents an analytic model. A model can be created directly:
# 
# >>> model = fastscore.Model('model-1')
# >>> model.mtype = 'python'
# >>> model.source = '...'
# 
# Or, retrieved from a Model Manage instance:
# 
# >>> mm = connect.lookup('model-manage')
# >>> model = mm.models['model-1']
# 
# A directly-created model must be saved to make attachment and snapshot
# manipulation functions available:
# 
# >>> mm = connect.lookup('model-manage')
# >>> model.update(mm)
# >>> model.attachments.names()
# []
# 
# """