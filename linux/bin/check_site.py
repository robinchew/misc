#!/usr/bin/env python
import time
import urllib2
import sys
import os
from datetime import datetime,timedelta

default_min = min = 15
if len(sys.argv) < 2:
    print 'Need 1 argument as url'
    sys.exit(0)

if len(sys.argv) > 2:
    proxy_url = sys.argv[2]
else:
    proxy_url = None 

url = sys.argv[1]
splitted_url = url.split('.')
domain = splitted_url[-2]
url_prefix = splitted_url[0]
has_http=False
has_www=False
    
if url_prefix.find('http') == 0:
    #first character in string starts with http
    has_http = True

if url_prefix.find('www') == 0: 
    #first character in string starts with www
    url = 'http://'+url
    has_www = True
    
if not has_http and not has_www:
    url = 'http://www.'+url
    
domain = splitted_url[-2]
this_file = sys.argv[0]
lock_file = '%s_lock_%s' % (this_file,domain)
pid = 0

# check for lock file
try:
    file = open(lock_file, 'rt') #t for text
    data = file.read()
    file.close()
    pid = int(data)
except IOError:
    pass

if pid:
    try:
        os.kill(pid,0) #the second argrument 0 makes sure nothing is actually killed, so this is used as a way to check whether the pid exists
        sys.exit(0) #pid exists and running, so quit
    except OSError:
        pass

# set lock pid file, to allow only one instance to run
file = open(lock_file,'wt') #t for text
file.write(str(os.getpid()))
file.close()


if len(sys.argv) == 2:
  while True: 
    date = datetime.now()
    try:
        site = urllib2.urlopen(url,timeout=15)
        print 'Found %s at %s' % (url,date.strftime('%H:%M'))
        min = default_min
    except (urllib2.HTTPError, urllib2.URLError), detail:
        status = '%s %s' % (url,detail)
        print status 

        from PyQt4 import QtGui
        app = QtGui.QApplication(sys.argv)
        mb = QtGui.QMessageBox()
        mb.setText(status) 
        mb.setModal(True)
        mb.exec_()
        min = 5
    except (KeyboardInterrupt,SystemExit):
        os.remove(lock_file)
        sys.exit(0)
    
    print 'Checking again in %s minutes at %s' % (min, (date+timedelta(minutes=min)).strftime('%H:%M'))

    time.sleep(min*60)
    
"""
if [ $1 ];then
  while true;do
    w3m -dump_head $1 | grep  -o '200 OK' 
    if [ $? -eq 1 ];then
      status = 'FAIL'
      notify-send -t 0 $status
      exit 0
    fi
    sleep 10
  done
fi
"""
