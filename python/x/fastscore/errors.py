
class FastScoreError(Exception):
    """
    A FastScore exception.

    SDK functions throw only FastScoreError exceptions. An SDK function is
    either succeeds or throws and exception. The return value of a SDK function
    is always valid.
    """

    def __init__(self, message, caused_by=None):
        self.message = message
        self.caused_by = caused_by

    def __str__(self):
        if self.caused_by != None:
            return "Error: %s\n  Caused by: %s" % (self.message,self.caused_by)
        else:
            return "Error: %s" % self.message
        
