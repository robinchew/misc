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
    -A INPUT -i lo -j ACCEPT
    -A INPUT -d 202.78.203.18/32 -p tcp -m tcp --sport 513:65535 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT  
    -A INPUT -d 202.78.203.18/32 -p tcp -m tcp --sport 513:65535 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT 
    -A INPUT -d 202.78.203.18/32 -p tcp -m tcp --sport 513:65535 --dport 5432 -m state --state NEW,ESTABLISHED -j ACCEPT 
    -A INPUT -d 202.78.203.19/32 -p tcp -m tcp --sport 513:65535 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT 
    -A INPUT -d 202.78.203.19/32 -p tcp -m tcp --sport 513:65535 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT  
    -A INPUT -d 202.78.203.19/32 -p tcp -m tcp --sport 513:65535 --dport 5432 -m state --state NEW,ESTABLISHED -j ACCEPT 
    -A INPUT -p tcp -m tcp --sport 53 -j ACCEPT                                    
    -A INPUT -p udp -m udp --sport 53 -j ACCEPT
    -A INPUT -p tcp -m tcp --sport 80 -j ACCEPT                                    
    -A INPUT -p tcp -m tcp --sport 22 -j ACCEPT
    -A INPUT -j DROP                                                               
    -A OUTPUT -o lo -j ACCEPT            
    -A OUTPUT -s 202.78.203.18/32 -p tcp -m tcp --sport 22 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT 
    -A OUTPUT -s 202.78.203.18/32 -p tcp -m tcp --sport 80 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT 
    -A OUTPUT -s 202.78.203.18/32 -p tcp -m tcp --sport 5432 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT 
    -A OUTPUT -s 202.78.203.19/32 -p tcp -m tcp --sport 22 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT 
    -A OUTPUT -s 202.78.203.19/32 -p tcp -m tcp --sport 80 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT
    -A OUTPUT -s 202.78.203.19/32 -p tcp -m tcp --sport 5432 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT
    -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT                                   
    -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
    -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT                                   
    -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT 
    -A OUTPUT -j DROP                                                              
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

DROP IP TABLE RULE
==================
# 5 represents the line number

iptables -L INPUT --line-numbers
iptables -D INPUT 5

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
