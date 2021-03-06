Main Goal
=========

To create and update issues using Redmine_ and Postfix_.

Arch Linux
==========

useradd -m redmine2
passwd
su redmine2
cd

svn co http://svn.redmine.org/redmine/branches/2.2-stable/ redmine-2.2

# These packages are needed for bundle installation
pacman -Syu --needed sudo git wget curl checkinstall libxml2 libxslt base-devel mysql++ zlib icu redis openssh python2 python2-pygments python2-pip libyaml ruby subversion imagemagick

pacman -S passenger ruby-rack

ruby-bundler https://aur.archlinux.org/packages/ruby-bundler/


# vim .bashrc
export PATH=/home/redmine2/.gem/ruby/1.9.1/bin:$PATH

# Temporarily give sudo access to redmine2
cd redmine-2.2
bundle install

# Remove sudo access and password

# Setup configuration based on example files
config/database.yml
config/configuration

RAILS_ENV=production rake db:migrate 
RAILS_ENV=production rake redmine:load_default_data

Setup email
/config/configuration.yml::

    default:
      email_delivery:
        delivery_method: :smtp
        smtp_settings:
          address: smtp.example.net
          port: 25
          domain: example.net
          authentication: :login
          user_name: "redmine@example.net"
          password: "redmine"

Log email
---------

Comment out the following line in config/environments/production.rb::

    # config.action_mailer.logger = nil

From: Email Header
------------------

See **emission-email.png** in folder of this file.

Change Administration > Settings > Email Notification > Emission email address::
    
    OBSI Redmine <redmine@obsi.com.au>

However, if config/configuration.yml contains::

    default:
      email_delivery:
        delivery_method: :smtp
        smtp_settings:
          ...
          user_name: "mailer@obsi.com.au"
          ...

Then the 'From:' header will replace 'redmine@obsi.com.au' with 'mailer@obsi.com.au' resulting with::

    OBSI Redmine <mailer@obsi.com.au>

Debian
======

sudo aptitude install ruby rubygems subversion ruby-pkg-tools ruby1.8-dev build-essential

rubygems maybe be too old, so do:
sudo gem update --system 

sudo gem install rails
sudo aptitude install sqlite3 libsqlite3-dev
sudo gem install sqlite3-ruby

rake db:migrate RAILS_ENV="production"
rake redmine:load_default_data RAILS_ENV="production"



----------- OR ----------------



$ sudo apt-get install ruby irb ri rdoc ruby1.8-dev libzlib-ruby libyaml-ruby libreadline-ruby libncurses-ruby libcurses-ruby libruby libruby-extras libfcgi-ruby1.8 build-essential libopenssl-ruby libdbm-ruby libdbi-ruby libdbd-sqlite3-ruby sqlite3 libsqlite3-dev libsqlite3-ruby libxml-ruby libxml2-dev


Find and download latest ruby gems, 1.3.5 maybe
$ tar -xvf rubygems-1.2.0.tgz 
$ cd rubygems-1.2.0/
$ ruby setup.rb
$ sudo ln -s /usr/bin/gem1.8 /usr/bin/gem (use this if /usr/bin/gem link is not created)

$ gem install rails

$ apt-get install apache2-threaded-dev 

$ gem install passenger

$ passenger-install-apache2-module 

8.Apache2 configuration changes:
$ cd /etc/apache2/sites-available/
$ sudo mv default default.bkp


-------- /etc/apache2/sites-available/default -----------
-------- configuration for only a single host -----------

LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.2.11/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.2.11
PassengerRuby /usr/bin/ruby1.8

RailsEnv production
#dont need below i think since this configuration is only for a single host 
#RailsBaseURI /redmine
NameVirtualHost *

ServerName  localhost

DocumentRoot /var/www/redmine/public

<Directory /var/www/redmine/public>
Options Indexes FollowSymLinks MultiViews
AllowOverride None
Order allow,deny
allow from all
</Directory>


ErrorLog /var/log/apache2/error.log

LogLevel warn

CustomLog /var/log/apache2/access.log combined
ServerSignature On


SUBMITING ISSUES BY EMAIL
=========================

MX Server
---------

You must set the MX server at wherever your DNS is hosted. For example, in Webfaction, assuming you have created a domain called, 'team.obsi.com.au', you have to go to that domain, and set Email as:

- External
- Priority: 1
- Mail Server: team.obsi.com.au

See attached screenshot it this file's folder named, **redmine-mx-server.png**

Postfix
-------

log in as admin
go to admin > settings > incoming email
enable WS email and generate and copy key 
install postfix
enable postfix daemon

Mail handler needs to be root executable because postfix daemon only runs as root::

    chmod 755 /srv/http/redmine-2.2/extra/mail_handler/rdm-mailhandler.rb

/etc/postfix/aliases::

    issue:  "|/srv/http/redmine-2.2/extra/mail_handler/rdm-mailhandler.rb --url http://team.obsi.com.au --key G93FmPu3SGVKjBPwuCXi --project bookings"

/etc/postfix/main.cf::

    alias_maps = hash:/etc/aliases # to forward local email to user
    inet_interfaces = all # for remote access
    virtual_alias_domains = team.obsi.com.au # to forward remote email
    virtual_alias_maps = hash:/etc/postfix/virtual # to forward remote email
    transport_maps = hash:/etc/postfix/transport # explained in Redmine Receiving Emails 

/etc/postfix/virtual::

    issue@team.obsi.com.au issue

/etc/postfix/transport::

    issue@team.obsi.com.au local:

Issue Attributes
----------------

When you mail a content with::
    
    This is the body text. Imagine this is the body that you send by email, including the text below, which are issue attributes.
    
    Tracker: Support
    Status: Resolved
    Priority: Low
    Project: obsi
    Assigned to: robin

then only 'Status' and 'Assigned to' will take effect by default. To get the other attributes working, you need to add the --allow-override argument to rdm-mailhandler.rb::

    rdm-mailhandler.rb --url http://team.obsi.com.au --key G93FmPu3SGVKjBPwuCXi --project bookings --allow-override project,tracker,category,priority

Other attributes include, however not all has been tested:: 

    project, tracker, status, priority, category, assigned to, fixed version (aka. Target version), start date, due date, estimated hours, done ratio.

Attributes can be written as the following with no problems::
     
     assigned to:robin
     Assigned To: robin

However 'robin' will have to be **exact** in its lowercase and uppercase::
    
    priority:Low // Correct
    priority:low // Wrong!

Refer to `issue attributes`_

Read REMEMBER TO DO THE FOLLOWING

REMEMBER TO DO THE FOLLOWING!!
------------------------------

::

    sudo newaliases # updates aliases specified in 'alias_maps'
    sudo postmap /etc/postfix/virtual # convert to a postfix readable format in /etc/postfix/virtual.db
    sudo postmap /etc/postfix/transport # convert to a postfix readable format in /etc/postfix/transport.db

    sudo systemctl restart postfix

OR::

    sudo sh -c "cd /etc/postfix;newaliases;postmap virtual;postmap transport;systemctl restart postfix"

TROUBLESHOOTING
---------------

Go to /var/www/redmine/config/environments/production.rb and comment out::

    #config.action_mailer.logger = nil

Test mail handler is working::

    echo 'message body'|mail -s 'Subject' user@mail.com|/srv/http/redmine-2.2/extra/mail_handler/rdm-mailhandler.rb --url http://team.obsi.com.au --key xxxxxxxxx --project bookings

If getting Mail Return errors with errors such as::
    
    permission denied. Command
    output: Request was denied by your Redmine server. Possible reasons: email
    is sent from an invalid email address or is missing some information.

And check logs at /var/www/redmine/log/production.log
You might come across a block of information such as::

    Message-ID: <BANLkTimGDaGc86q4h4Cm=+ThKAU+HYpN7Q@mail.gmail.com>
    Subject: issee
    From: Robin Chew <robinchew@gmail.com>
    To: issue@team.obsi.com.au
    Content-Type: text/plain; charset=ISO-8859-1

    Validation failed: Browser can't be blank
    Completed in 281ms (View: 0, DB: 45) | 422 Unprocessable Entity [http://team.obsi.com.au/mail_handler]

Which tells you that the Mail Return error is caused by the Browser field being required but the mail body does not include.
Solution was to make Browser field not required, or has a default value already set.

REFERENCES
----------

.. target-notes::

.. _postfix: https://help.ubuntu.com/community/PostfixBasicSetupHowto
.. _redmine: http://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails
.. _issue attributes: http://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails#Issue-attributes
