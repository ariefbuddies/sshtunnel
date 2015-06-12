#!/bin/bash

###############
## Use ssh's SOCKS proxy functionality to tunnel traffic over a given local port
## Uses firefox's profiles to establish a new Firefox session/settings to establish
##  an encrypted tunnel
##
##
##  Browser Setup
##   == Firefox Settings ==
##    === New Profile ===
##    Create a new profile by closing all Firefox instances(killall firefox)
##    Now issue firefox -ProfileManager to get the profile manager to show
##    Create a new profile and name it Tunnel
##  
##    === about:config ===
##    Once firefox is open head to about:config in the address bar
##    Set network.proxy.socks to 127.0.0.1
##    Set network.proxy.socks_port to the same port as you set localport below(8080 is default)
##    Set network.proxy.socks_remote_dns to true
##    Set network.proxy.type to 1
##   
##  == Script Setup == 
##  Set user to the remote user you want to use
##  Set host to the remote host you wish to tunnel through
##  Set remote port to the port you wish to connect to on the remote host(Default is 443(https) as it almost gaurantees to be open)
##  Set local port to a local port you will use(You will set your web browser's settings to this port
##  Log file can be any path to a file where log information will be sent
##
##  == Remote Setup ==
##  Obviously you will need to have an account and be able to ssh to the remote port you specify
##  It is quite easy to tell openssh server to listen on additional ports. Just edit your sshd_config file and change the listen port
##  Probably just listen = 80,443 or something similar
##
##  == Extra Remarks ==
##  I made a shortcut to execute this script and it is easy as pie
##  If you are really lazy you could setup ssh keys so you don't have to enter a password every time you open the tunnel

user="my.username"
host="myhostname"
localport=8080
remoteport=443
log=tunnel.log
cmd="ssh -fCNT -D $localport $host -p $remoteport"

date | tee -a $log

pid=$(pgrep -fu $USER "$cmd")

# Is the tunnel already open?
if [ "$pid" == "" ]
then
    # Open tunnel
    echo "Openning tunnel" | tee -a $log
    $cmd
    pid=$(pgrep -fu $USER "$cmd")
else
    echo "Tunnel already exists" | tee -a $log
fi
echo "PID of SSH Tunnel: $pid" | tee -a $log

firefox -P Tunnel -no-remote
wait

# Kill the tunnel
echo "Tearing down tunnel" | tee -a $log
kill $pid | tee -a $log
date | tee -a $log
