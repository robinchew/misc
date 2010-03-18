#!/usr/bin/env python
import getpass, imaplib
import re
import os
import time

min = 5

print "Running Python Gmail Notifier..."
while True:
    try:
        M = imaplib.IMAP4_SSL('imap.gmail.com',993)
        #M.login('robinchew', getpass.getpass())
        M.login('robinchew', 'zer0c212')
        M.select('[Gmail]/All Mail')
        last_mail_id_str = int(M.search(None,"UNSEEN")[1][0].split()[-1])
        last_mail_id = int(last_mail_id_str) 
        print 'latest id %s' % last_mail_id_str

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
            print 'last saved %s' % saved_mail_id_str 
            saved_mail_id = int(saved_mail_id_str) 

            if last_mail_id > saved_mail_id:
                for i in xrange(saved_mail_id+1,last_mail_id+1):
                    last_mail_content = M.fetch(i,'RFC822')[1][0][1]

                    subject_re = re.compile('Subject: (.*?)\r')
                    subject = subject_re.search(last_mail_content).group(1)
                    os.popen('/usr/bin/notify-send -t 0 "%s"' % subject)

                M.close()
                M.logout()
                    
                file = open(mail_file_path,'w')
                file.write(str(i)) # i should be the last loop with the last mail id
                file.close()
            else:
                print 'no new mail'
        else:
            # file empty
            saved_mail_id_str = last_mail_id_str
            file = open(mail_file_path,'w')
            file.write(saved_mail_id_str)
            file.close()

    except (KeyboardInterrupt,SystemExit):
        sys.exit(0)

    time.sleep(min*60)
