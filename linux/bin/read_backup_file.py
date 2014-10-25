#!/usr/bin/env python
import sys, re, os
from datetime import datetime
from num2words import num2words
size, file_name = sys.stdin.read().split(' ')

year, month, day, hour, minute = re.split('[-_:.]', os.path.basename(file_name), 4)
date = datetime(*[int(i) for i in (year, month, day)])
month_name = date.strftime('%B')
week_day = date.strftime('%A')

# File is mispelt Fal, so that text to speech pronounce it better
print '3. 2. 1.', 'Last backup is on,', num2words(int(day), ordinal=True), 'of', month_name, ',', week_day, '. Fal size is ', size
