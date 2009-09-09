import datetime

today = datetime.date.today()

print "The date is", today.day


timediff = datetime.datetime.now() - datetime.datetime(2009, 2, 4)
print timediff

now = datetime.date.now()
difference1 = datetime.timedelta(days=1)
difference2 = datetime.timedelta(weeks=-2)

print "One day in the future is:", now + difference1
