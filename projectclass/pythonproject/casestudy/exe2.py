
#write to find the number between 1000 and 3000 
items = []
for i in range(1000,3000):
    s = str(i)
    if (int(s[0])%2==0) and (int(s[1])%2==0) and (int(s[2])%2==0):
        items.append(s)
print(','.join(items))



#write sentence and caculate the number of letter

s = input("python0325")
d=l=0
for c in s:
    if c.isdigit():
        d=d+1
    elif c.isalpha():
        l=l+1
    else:
print("Letters", l)
print("Digits", d")
