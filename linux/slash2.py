import re
import urllib2,datetime

import os,sys

slashdot_current_date = datetime.datetime.utcnow()-datetime.timedelta(hours=5)

if len(sys.argv) == 2:
  if '-' == sys.argv[1][0]:
        #split=sys.argv[1].index('-')
	num=int(sys.argv[1])
	date=slashdot_current_date+datetime.timedelta(hours=num)
  else:
	today=datetime.dateetime.now()
	date=datetime.datetime(today.year,today.month,int(sys.argv[1]))
  
elif len(sys.argv) == 3:
	today=datetime.datetime.now()
	date=datetime.datetime(today.year,int(sys.argv[2]),int(sys.argv[1]))
    
else:
	date=slashdot_current_date

print date.strftime('%Y%m%d') 
html = urllib2.urlopen('http://slashdot.org/index.pl?issue=%s' % date.strftime('%Y%m%d')).read()
#html = urllib2.urlopen('http://slashdot.org/').read()
#html=open('test','r').read()
#pattern = r'<a.*?>.*?<a.*?href="(.*?)" class="datitle">(.*?)</a>.*?(\d{1,2}), @(\d{1,2}):(\d{1,2})(..)'
pattern = r'<span><a.*?>.*?<a.*?href="(.*?)".*?>(.*?)<(?:.*\n)*?\s*on.*?(\d{1,2}), @(\d{1,2}):(\d{1,2})(..)'
regex = re.compile(pattern, re.MULTILINE)
"""
for match in regex.finditer(html):
  print '1-%s'% match.group(1)
  print '2-%s'% match.group(2)
  print '3-%s'% match.group(3)
  print '4-%s'% match.group(4)
  print '5-%s'% match.group(5)
  print '6-%s'% match.group(6)
"""
for match in regex.finditer(html):
  url='http:'+match.group(1)
  title=match.group(2)
  #title=re.sub('\$',"S|",title)
  title=re.sub('\/',"_",title)
  title=re.sub('\|',"_",title)
  title=re.sub(':',"_",title)
  title=re.sub('\<',"_",title)
  title=re.sub('\>',"_",title)
#  title=re.sub("\\\'"," ",title)
  title=title.decode('string_escape')
  title=re.sub('"',"'",title)
  title=re.sub('\?','(q)',title)
  day=re.sub(':','',match.group(3))
  hour=re.sub(':','',match.group(4))
  min=re.sub(':','',match.group(5))
  ampm=re.sub(':','',match.group(6))
  if ampm == 'PM' and hour != 12:
    hour=int(hour)+12
  folder='slashdot%s%s' % (date.year,date.month)
  if not os.path.exists(folder):
    os.mkdir(folder)
  filename='%s/%s,%s%s-%s' % (folder,day,hour,min,title)
  print filename
  try:
      page = urllib2.urlopen(url)

  except urllib2.URLError, e:
      error_msg="Error opening "+url
      print error_msg

  try:
    save_page=open(filename,'w')
  except IOError:
	  try:
	    save_page=open(filename[0:-1],'w')
	  except IOError:
	    save_page=open(filename,'w')
	    error_msg="Error saving "+title+" from "+url+" to "+filename
	    print error_msg
	    print url 
	    sys.exit()
    
  save_page.writelines(page.read())
  save_page.close()
  print 'Saved'
