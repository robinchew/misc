# initialize.py
# Dave's initialization file for Python interactive sessions.

# save this file in $HOME
# save following line to .profile  or .bashrc
# export PYTHONSTARTUP=$HOME/initialize.py

import sys, os, readline

histfile = os.path.join(os.environ["HOME"], ".pyhist")
try:
    readline.read_history_file(histfile)
except IOError:
    pass
import atexit
atexit.register(readline.write_history_file, histfile)
del os, histfile


try:
    import readline
except ImportError:
    print "Module readline not available."
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")

"""
try:
    import settings
except:
    print 'no settings'
    sys.exit(0)

from django.core.management import setup_environ
#from django.conf import settings  #this way doesn't work for some reason, must do below
setup_environ(settings)
"""
