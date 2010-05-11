#!/usr/bin/env python
import getpass, imaplib, re, os, sys, time
from datetime import datetime

min = 5
if len(sys.argv) > 1 and sys.argv[1]:
    wait = int(sys.argv[1]) # seconds
else:
    wait = 0 # seconds

if wait:
    print "Waiting %s seconds for wireless to connect" % wait
    time.sleep(wait) # wait 10 seconds for wireless to connect

print "Running Python Gmail Notifier..."

while True:
    try:
        M = imaplib.IMAP4_SSL('imap.gmail.com',993)
        #M.login('robinchew', getpass.getpass())
        M.login('robinchew', 'zer0c212')
        M.select('[Gmail]/All Mail')
        latest_mail_id_str = int(M.search(None,"UNSEEN")[1][0].split()[-1])
        latest_mail_id = int(latest_mail_id_str) 

        this_dir = os.path.dirname(__file__)
        mail_file_path = os.path.join(this_dir,'mail_id')
        if os.path.isfile(mail_file_path):
            pass
        else:
            file = open(mail_file_path,'w')
            file.close()
        
        file = open(mail_file_path,'r')
        saved_mail_id_str = file.read()
        file.close()
        if saved_mail_id_str:
            # file has content
            saved_mail_id = int(saved_mail_id_str) 

            if latest_mail_id > saved_mail_id:
                print 'last saved %s' % saved_mail_id_str 
                print 'latest     %s' % latest_mail_id_str

                notify_in_file = latest_mail_id - saved_mail_id > 20

                if notify_in_file:
                    today=datetime.now().strftime('%y%m%d_%H:%M')
                    notify_file_path = os.path.join(this_dir,'long_notifications_%s' % today)
                    notify_file = open(notify_file_path,'w')

                for i in xrange(saved_mail_id+1,latest_mail_id+1):
                    last_mail_content = M.fetch(i,'RFC822')[1][0][1]

                    subject_re = re.compile('Subject: (.*?)\r')
                    try:
                        subject = subject_re.search(last_mail_content).group(1)
                    except AttributeError:
                        subject = 'No Subject'
                    if not notify_in_file:
                        # use notify-send if only notifying less than 20 messages
                        os.popen('/usr/bin/notify-send -t 0 "%s"' % subject)
                    else:
                        # write to file if notifying more than 20 messages
                        notify_file.write(subject+'\n')

                if notify_in_file:
                    # notifications written to file
                    notify_file.close()
                    os.popen('/usr/bin/notify-send -t 0 "Open %s to see new mail subjects"' % notify_file_path)

                M.close()
                M.logout()
                    
                file = open(mail_file_path,'w')
                file.write(str(i)) # i should be the last loop with the last mail id
                file.close()
            else:
                print '%s - no new mail' % datetime.now().strftime('%H:%M')
        else:
            # file empty
            saved_mail_id_str = latest_mail_id_str
            file = open(mail_file_path,'w')
            file.write(saved_mail_id_str)
            file.close()

    except (KeyboardInterrupt,SystemExit):
        sys.exit(0)

    time.sleep(min*60)
