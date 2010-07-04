import re
import urllib2,datetime
import time
import os,sys

test_only = False

slashdot_current_date = datetime.datetime.utcnow()-datetime.timedelta(hours=5)

final_year = 0 
final_month = 0 

if 4 <= len(sys.argv) <= 5:
    # argument has cmd,year,month,day
    # eg. slash2.py 2010 5 6
    if '-' in sys.argv[3]:
        # argument contains day range
        # eg. slashe2.py 2010 6 10-20
        start_day,end_day = sys.argv[3].split('-')
        start_day = int(start_day)
        end_day = int(end_day)+1
    else:
        # argument contains just 1 day
        # eg. slashe2.py 2010 6 10
        start_day = int(sys.argv[3])
        end_day = start_day+1

    final_year = int(sys.argv[1])
    final_month = int(sys.argv[2])

    if len(sys.argv) == 5:
        test_only = True
    
else:
    if len(sys.argv) == 2 and '-' == sys.argv[1][0]:
        days = int(sys.argv[1])
        num_hours = days * 24
        today = slashdot_current_date - datetime.timedelta(hours=num_hours)
    else:
        today = slashdot_current_date

    start_day = today.day
    end_day = start_day + 1 
    final_month = today.month
    final_year = today.year

def fetch_headlines(date):
    #pattern = r'<a.*?>.*?<a.*?href="(.*?)" class="datitle">(.*?)</a>.*?(\d{1,2}), @(\d{1,2}):(\d{1,2})(..)'
    pattern = r'<span><a.*?>.*?<a.*?href="(.*?)".*?>(.*?)<(?:.*\n)*?\s*on.*?(\d{1,2}),.*?(\d{1,2}):(\d{1,2}).*?([APMapm]{2})'
    #pattern = r'<span><a.*?>.*?<a.*?href="(.*?)".*?>(.*?)<(?:.*\n)*?\s*on.*?(\d{1,2}), @(\d{1,2}):(\d{1,2})(..)'
    regex = re.compile(pattern, re.MULTILINE)
    index_url='http://slashdot.org/index.pl?issue=%s' % date.strftime('%Y%m%d')

    print index_url 

    if not test_only:
        html = urllib2.urlopen(index_url).read()
    else:
        html=open('test.html','r').read()
        i=1
        for match in regex.finditer(html):
          i+=1
          print '1-%s'% match.group(1)
          print '2-%s'% match.group(2)
          print '3-%s'% match.group(3)
          print '4-%s'% match.group(4)
          print '5-%s'% match.group(5)
          print '6-%s'% match.group(6)
        print '%s matches'%i
        sys.exit()

    test_page=open('test.html','w')
    test_page.writelines(html)
    test_page.close()
    print 'saved test index'

    i=0
    for match in regex.finditer(html):
      i+=1
      url='http:'+match.group(1)
      title=match.group(2)
      #title=re.sub('\$',"S|",title)
      title=re.sub('\/',"_",title)
      title=re.sub('\|',"_",title)
      title=re.sub(':',"_",title)
      title=re.sub('\<',"_",title)
      title=re.sub('\>',"_",title)
      title=re.sub('\*',"_",title)
    #  title=re.sub("\\\'"," ",title)
      title=title.decode('string_escape')
      title=re.sub('"',"_",title)
      title=re.sub("'","_",title)
      title=re.sub('\?','(q)',title)
      day=re.sub(':','',match.group(3))
      hour=re.sub(':','',match.group(4))
      min=re.sub(':','',match.group(5))
      ampm=re.sub(':','',match.group(6))
      if ampm == 'PM' and int(hour) != 12:
        hour=int(hour)+12
      folder='slashdot%s%s' % (date.year,date.month)
      if not os.path.exists(folder):
        os.mkdir(folder)
      filename='%s/%s,%s%s-%s.html' % (folder,day,hour,min,title)
      print filename
      try:
          page = urllib2.urlopen(str(url))

      except urllib2.URLError, e:
          error_msg="Error opening "+url
          print error_msg
          print e
          sys.exit()

      try:
        save_page=open(filename,'w')
      except IOError:
          try:
            save_page=open('%s___' % filename[0:-1],'w')
          except IOError:
            error_msg="Error saving "+title+" from "+url+" to "+filename
            print error_msg
            print url 
            sys.exit()
      article_html=page.read().replace('<head>','<head><link rel="stylesheet" type="text/css" href="../slashdot.css" />')  
      save_page.writelines(article_html)
      save_page.close()
      print 'Saved'
      for j in [3,2,1]:
        print j
        time.sleep(1)

    print '%s saves' %i

    try:
        import osso
        osso_c = osso.Context("osso_test_note", "0.0.1", False)
        note = osso.SystemNote(osso_c)
        note.system_note_dialog('Downloaded', type='notice')
    except ImportError:
        pass

for day in xrange(start_day,end_day):
    # get page of each date
    date=datetime.datetime(final_year,final_month,day)
    fetch_headlines(date)
