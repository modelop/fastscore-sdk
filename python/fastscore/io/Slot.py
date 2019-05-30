class Slot(object):

    def __init__(self, n):
        self.state = acquireSlotState(n)

    def __iter__(self):
        return self

    def __next__(self):
        data = self.read()
        if data is None:
            raise StopIteration
        else:
            return data

    def read(self, format='pandas', with_seqno=False):
        if format != 'pandas':
            raise ValueError("format must be 'pandas'")
        if self.state.dataframes:
            return self.state.dataframes.pop()
        return None

    def write(self, rec):
        self.state.write(rec)

    def load(self, dataframes):
        self.state.load(dataframes)

    def output(self):
        return self.state.output

    def reset(self):
        self.state.output = []


class SlotState(object):

    def __init__(self):
        self.output = []

    def write(self, rec):
        self.output.append(rec)

    def load(self, dataframes):
        if isinstance(dataframes, list):
            self.dataframes = dataframes
            self.dataframes.reverse()
        else:
            self.dataframes = [dataframes]


__slotState = dict()
__slotState[0] = SlotState()
__slotState[1] = SlotState()

def acquireSlotState(n):
    return __slotState[n]
