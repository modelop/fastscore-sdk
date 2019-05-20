class Slot(object):

    def __init__(self, n):
        self.state = acquireSlotState(n)

    def read(self, format='pandas', with_seqno=False):
        if format != 'pandas':
            print "Format '%s' not supported" % format
            sys.exit(1)
        return self.state.dataframe

    def write(self, rec):
        self.state.write(rec)

    def load(self, dataframe):
        self.state.load(dataframe)

    def output(self):
        return self.state.output

    def reset(self):
        self.state.output = []


class SlotState(object):

    def __init__(self):
        self.output = []

    def write(self, rec):
        self.output.append(rec)

    def load(self, dataframe):
        self.dataframe = dataframe


__slotState = dict()
__slotState[0] = SlotState()
__slotState[1] = SlotState()

def acquireSlotState(n):
    return __slotState[n]
