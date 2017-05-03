from IPython.core.magic import (Magics, magics_class, line_magic,
                                cell_magic, line_cell_magic)
import types

# Python2 vs Python3
import six
USE_PY3 = False
if six.PY2:
    from fastscore.py2model import Py2Model
    from fastscore.pfamodel import PFAModel # PFA only supported in PY2
if six.PY3:
    from fastscore.py3model import Py3Model
    USE_PY3 = True

# import the main module...
# we need to do this to access the global namespace.
import __main__ as main_mod

@magics_class
class IPMagic(Magics):

    @cell_magic
    def py2model(self, line, cell):
        """
        Magic used to indicate a cell where a Python2 model is defined.
        Note that the code in the cell is also evaluated, and is
        globally accesible.
        """
        if USE_PY3:
            raise ImportError("Python2 models are not supported in Python3")
        mymodel = Py2Model.from_string(cell, main_mod.__dict__)
        main_mod.__dict__['_model'] = mymodel
        print('Python2 Model loaded, and bound to the \'_model\' variable.')
        return mymodel

    @cell_magic
    def py3model(self, line, cell):
        """
        Magic used to indicate a cell where a Python2 model is defined.
        Note that the code in the cell is also evaluated, and is
        globally accesible.
        """
        if not USE_PY3:
            raise ImportError("Python3 models are not supported in Python2")
        mymodel = Py3Model.from_string(cell, main_mod.__dict__)
        main_mod.__dict__['_model'] = mymodel
        print('Python3 Model loaded, and bound to the \'_model\' variable.')
        return mymodel

    @cell_magic
    def pfamodel(self, line, cell):
        """
        Magic used to indicate a cell where a PFA model is defined.
        """
        if USE_PY3:
            raise ImportError("PFA models are not supported in Python3")
        mymodel = PFAModel.from_string(str(cell))
        main_mod.__dict__['_model'] = mymodel
        print('PFA model loaded, and bound to the \'_model\' variable.')
        return mymodel

    @cell_magic
    def ppfamodel(self, line, cell):
        """
        Magic used to indicate a cell where a PrettyPFA model is defined.
        """
        if USE_PY3:
            raise ImportError("PPFA models are not supported in Python3")
        mymodel = PFAModel.from_ppfa(str(cell))
        main_mod.__dict__['_model'] = mymodel
        print('PrettyPFA model loaded, and bound to the \'_model\' variable.')
        return mymodel


# The following lines make it so that running "import ipmagic"
# adds the magic above to the notebook

# In order to actually use these magics, you must register them with a
# running IPython.  This code must be placed in a file that is loaded once
# IPython is up and running:
ip = get_ipython()
# You can register the class itself without instantiating it.  IPython will
# call the default constructor on it.
ip.register_magics(IPMagic)
