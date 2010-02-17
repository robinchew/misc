#!/usr/bin/env python
import sys
from django.utils import simplejson as json

if not sys.argv[1]:
  print 'please include filename'
  exit

fr=open(sys.argv[1],'r')
j=json.load(fr)
fr.close()

fw=open(sys.argv[1],'w')
fw.write(json.dumps(j,indent=4))
fw.close()
print 'seems done'
exit
