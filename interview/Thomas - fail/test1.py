import time
import datetime

def func(i):
  return datetime.datetime.now()+datetime.timedelta(days=i)



print "date is", func(4)

