from IPython.core.magic import (Magics, magics_class, line_magic,
                                cell_magic, line_cell_magic)
import types
from py2model import Py2Model

# import the main module...
# we need to do this to access the global namespace.
import __main__ as main_mod

@magics_class
class IPMagic(Magics):

    @cell_magic
    def model_def(self, line, cell):
        """
        Magic used to indicate a cell where a model is defined.
        Note that the code in the cell is also evaluated, and is
        globally accesible.
        """
        mymodel = Py2Model.from_string(cell, main_mod.__dict__)
        main_mod.__dict__['_model'] = mymodel
        print 'Model loaded, and bound to the \'_model\' variable.'
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
