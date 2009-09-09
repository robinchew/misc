import time
import datetime

def tests(i):

	s = datetime.timedelta(days=i)
	now = datetime.date.today()
	return  now + s


def tests2(y,m,d):

	input = datetime.datetime (y,m,d)
	now = datetime.datetime.today()
	diff = now - input
	days = diff.days
	return days

print tests2(2009,1,10)	