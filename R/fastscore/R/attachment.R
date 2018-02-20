
# class Attachment(object):

# Represents a model attachment. An attachment can be created directly but it must (ultimately) associated with the model:
# 
# >>> att = fastscore.Attachment('att-1', datafile='/tmp/att1.zip')
# >>> model = mm.models['model-1']
# >>> att.upload(model)
# 
# :param atype: An attachment type. Guessed from the data file name if omitted.
# :param datafile: The data file.
# :param model: The model instance.
