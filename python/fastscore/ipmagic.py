from IPython.core.magic import (Magics, magics_class, line_magic,
                                cell_magic, line_cell_magic)
import types
from py2model import Py2Model
from pfamodel import PFAModel

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
        mymodel = Py2Model.from_string(cell, main_mod.__dict__)
        main_mod.__dict__['_model'] = mymodel
        print 'Python2 Model loaded, and bound to the \'_model\' variable.'
        return mymodel

    @cell_magic
    def pfamodel(self, line, cell):
        """
        Magic used to indicate a cell where a PFA model is defined.
        """
        mymodel = PFAModel.from_string(str(cell))
        main_mod.__dict__['_model'] = mymodel
        print 'PFA model loaded, and bound to the \'_model\' variable.'
        return mymodel

    @cell_magic
    def ppfamodel(self, line, cell):
        """
        Magic used to indicate a cell where a PrettyPFA model is defined.
        """
        mymodel = PFAModel.from_ppfa(str(cell))
        main_mod.__dict__['_model'] = mymodel
        print 'PrettyPFA model loaded, and bound to the \'_model\' variable.'
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
