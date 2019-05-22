# fastscore.input: array-double
# fastscore.output: string

# To properly use this model, make sure to run it with one of the 'file-contains-XXXX.tgz' attachments in the library/attachments directory.
# This model ignores the input, and just emits the contents of the attachment.

def action(datum):
    the_file = open("file.txt", "r")
    yield the_file.read()
