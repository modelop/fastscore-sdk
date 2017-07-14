import six
if six.PY2:
    from .py2model import Py2Model
    from .pfamodel import PFAModel
if six.PY3:
    from .py3model import Py3Model

try:
    import ipmagic
except NameError:
    pass
