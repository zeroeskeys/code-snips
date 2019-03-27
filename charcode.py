# interactive convert unicode 

charcode = input ("enter the Charcode string to be converted to Dec code: ")
print(charcode + " Is this correct?")
input("Press Enter to continue...")
ord_key=",".join(map(str,[ord(c) for c in charcode]))
print (ord_key)
