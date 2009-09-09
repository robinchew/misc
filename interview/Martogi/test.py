import datetime

def test(i):
 r = datetime.datetime.today().day+i, datetime.datetime.today().month, datetime.datetime.today().year
 return r

print test(4)

def test2(date):
   r = datetime.datetime.today()-datetime.datetime(date)
   return r

print test2(datetime.date(2009,02,11))