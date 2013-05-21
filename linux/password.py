import sys,random

try:
    length = int(sys.argv[1])
except IndexError:
    length = 12

letters = 'abcdefghijklmntopqrstuvwxyzABCDEFGHIJKLMNTOPQRSTUVWXYZ0123456789'
symbols = '#!@+-';

password =  ''.join( letters[random.randint(0,len(letters)-1)] for i in range(0,length) )  

# Check for at least 1 symbol in password
# print password if found

for char in password:
    if char in symbols:
        print(password)
        sys.exit()
        break

# Symbol not found in password
# so add it somewhere in the password

symbol = symbols[random.randint(0,len(symbols)-1)]

i = random.randint(0,len(password)-1)

print(password[0:i]+symbol+password[i+1:])
