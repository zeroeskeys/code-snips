# From https://github.com/allyshka/vhostbrute/blob/master/vhostbrute.py at line 338

def progress_update(i):
    sys.stdout.write("\r")
    sys.stdout.write("[%-50s] %.1f%%" % ('=' * int(i / 2), i))
    sys.stdout.flush()
