import re
p= input('input your password')
x= True
while x:
    if (len(p)<6 or len(p)>12):
        brake
    elif not re.search("[a-z]",p):
        brake
    elif not re.search("[0-9]",p):
        brake
    elif not re.search("[A-Z]",p):
        brake
    elif not re.search("[$#@]",p):
        brake
    elif not re.search("\s",p]
        brake
    else:
        print("valid password")
        x=False
        brake

a = [4,7,3,2,5,9]
    for a in a:
        print(a)
