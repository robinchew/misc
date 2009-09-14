#!/bin/sh
echo 'Make sure you have your own db_default.py in ..python2.5/site-packages/trac/'
echo ''
sudo trac-admin $1 initenv
sudo chown -R www-data:$2 $1
sudo chmod -R g+w $1

grep '\[components\]' $1/conf/trac.ini
if [ $? != 0 ];then
    echo '
    [components]
    acct_mgr.admin.accountmanageradminpage = enabled
    acct_mgr.api.accountmanager = enabled
    acct_mgr.db.sessionstore = enabled
    acct_mgr.htfile.abstractpasswordfilestore = enabled
    acct_mgr.htfile.htdigeststore = enabled
    acct_mgr.htfile.htpasswdstore = enabled
    acct_mgr.http.httpauthstore = enabled
    acct_mgr.notification.accountchangelistener = enabled
    acct_mgr.notification.accountchangenotificationadminpanel = enabled
    acct_mgr.pwhash.htdigesthashmethod = enabled
    acct_mgr.pwhash.htpasswdhashmethod = enabled
    acct_mgr.svnserve.svnservepasswordstore = enabled
    acct_mgr.web_ui.accountmodule = enabled
    acct_mgr.web_ui.emailverificationmodule = disabled
    acct_mgr.web_ui.loginmodule = enabled
    acct_mgr.web_ui.registrationmodule = enabled
    permredirect.filter.permredirectmodule = disabled
    trac.web.auth.loginmodule = disabled
    tracsectionedit.web_ui.wikisectioneditmodule = enabled
    tracwysiwyg.templateprovider = enabled
    tracwysiwyg.wysiwygwikifilter = enabled
    autocompleteusers.* = enabled
    ' | sudo tee -a $1/conf/trac.ini

    sudo perl -i -pe 's:\[account-manager\]:$&\npassword_file = /etc/apache2/htpasswd/dav_svn.passwd\npassword_store = HtPasswdStore:' $1/conf/trac.ini 
fi

sudo perl -i -pe 's:account_changes_notify_addresses.*$:account_changes_notify_addresses = robinchew\@gmail.com:' $1/conf/trac.ini

sudo perl -i -pe 's:notify_actions.*$:notify_actions = new,change,delete:' $1/conf/trac.ini

sudo perl -i -pe 's:restrict_owner.*$:restrict_owner = true:' $1/conf/trac.ini

#sudo perl -i -pe 's:default_priority.*$:default_priority = minor:' $1/conf/trac.ini

sudo perl -i -pe 's:smtp_enabled.*$:smtp_enabled = true:' $1/conf/trac.ini

sudo perl -i -pe 's:max_size.*$:max_size = 26214400:g' $1/conf/trac.ini

sudo perl -i -pe 's:always_notify_owner.*$:always_notify_owner = true:g' $1/conf/trac.ini

sudo perl -i -pe 's:always_notify_reporter.*$:always_notify_reporter = true:g' $1/conf/trac.ini
