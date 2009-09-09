import time
import datetime

def test(add):
   print "current date"
   now = datetime.date.today()
   print now
   print add, "days after current time"
   print now + datetime.timedelta(days=add)
test(4)

def test2(date):
   print "current date test2"
   now = datetime.datetime.now()
   difference = date - now
   print difference

test2(datetime.datetime.strptime('2009-2-28','%Y-%m-%d'))

def test3(str):
   print "test3"
   now = datetime.datetime.today()
   difference = datetime.datetime.strptime(str,'%Y/%m-%d') - now
   print difference

test3('2009/2-27')
