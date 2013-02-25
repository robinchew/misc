 IPTables Configuration
 ######################

 Jumps

 - http://www.frozentux.net/iptables-tutorial/chunkyhtml/c3965.htmlhttp://www.frozentux.net/iptables-tutorial/chunkyhtml/c3965.html

 Tabless and chains

 - http://www.frozentux.net/iptables-tutorial/chunkyhtml/c962.html
 - http://www.thegeekstuff.com/2011/01/iptables-fundamentals/

 List iptables::

    iptables -L

You need to allow ESTABLISHED and RELATED traffic to come through your firewall::

    # -A means append
    # -I means insert and appends before or after specified rule number of a chain (INPUT 1, OUTPUT 2, etc.)
    # -R means replace and is similar to -I but replaces instead of append
    # -m means match (state, tcp, etc.)
    # -j means jump, what to do when packet matches (ACCEPT, DROP, etc). 

    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

Enable traffic to leave your machine by allowing all outgoing traffic as the default policy, ::

    # -P means policy

    iptables -P OUTPUT ACCEPT

STRICT IPTABLES RULES
=====================

Explanation of [0:0] in http://www.linuxquestions.org/questions/linux-networking-3/those-%5B-damn-brackets-%5D-in-iptables-must-be-there-for-a-reason-619556/

vim /etc/default/ipconfig::

    *filter
    :INPUT DROP [0:0]
    :FORWARD DROP [0:0]
    :OUTPUT DROP [0:0]

    ############################################
    # Other computers can ssh to this computer #
    ############################################

    -A INPUT  -p tcp --dport 22 -j ACCEPT
    -A OUTPUT -p tcp --sport 22 -j ACCEPT

    ############################################
    # This computer can ssh to other computers #
    ############################################

    -A INPUT  -p tcp --sport 22 -j ACCEPT
    -A OUTPUT -p tcp --dport 22 -j ACCEPT

    #######################################################
    # Other computers can visit this web server's website #
    #######################################################

    # We do NOT need to open port 53 to other computers 
    # because they they will be querying the DNS server 
    # from elsewhere because the DNS server isn't on 
    # this computer
    #
    # -A INPUT  -p udp --dport 53 -j ACCEPT
    # -A OUTPUT -p udp --sport 53 -j ACCEPT

    -A INPUT  -p tcp --dport 80 -j ACCEPT
    -A OUTPUT -p tcp --sport 80 -j ACCEPT

    ##########################################
    # This computer can visit other websites #
    ##########################################

    -A INPUT  -p udp --sport 53 -j ACCEPT
    -A OUTPUT -p udp --dport 53 -j ACCEPT

    -A INPUT  -p tcp --sport 80 -j ACCEPT
    -A OUTPUT -p tcp --dport 80 -j ACCEPT

    -A INPUT  -p tcp --sport 443 -j ACCEPT
    -A OUTPUT -p tcp --dport 443 -j ACCEPT
    COMMIT

Save iptables rules
-------------------

iptables-save > file.txt

Restore iptables configurations on network up
---------------------------------------------

vim /etc/network/interfaces::

    iface eth0 inet static
        pre-up iptables-restore < /etc/default/ipconfig

http://www.thegeekstuff.com/2011/06/iptables-rules-examples/

LOG PACKETS
===========

Example::

    iptables -A OUTPUT -j LOG --log-prefix anything

In Arch Linux, you can see the log with 'dmesg' or 'tail' dmesg by running::

    cat /dev/kmsg

DROP IP TABLE RULE
==================
# 5 represents the line number

iptables -L INPUT --line-numbers
iptables -D INPUT 5

BLOCK URL
=========

Example::

    sudo iptables -I OUTPUT -p tcp --dport 80 -m string --string "http://localhost:8000/basic" --algo kmp -j DROP

aMule
=====

If you set TCP port in aMule to XX and UDP port to YY then you have to set your firewall like this:

iptables -A INPUT -p tcp --dport XX -j ACCEPT
iptables -A INPUT -p udp --dport XX+3 -j ACCEPT
iptables -A INPUT -p udp --dport YY -j ACCEPT

iptables -A INPUT -p tcp --dport XX -j ACCEPT
iptables -A INPUT -p tcp --dport 6667 -j ACCEPT
iptables -A INPUT -p tcp --dport 6685 -j ACCEPT
iptables -A INPUT -p udp --dport 4672 -j ACCEPT
