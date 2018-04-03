#!/bin/bash

# svirepunchik@gmail.com (c) 2018
# firewall test script uninstaller

iam=`whoami`
echo $iam;

if [[ $iam != "root" ]]; then echo "you must be root. please run sudo ./uninstall.sh"; exit 1; fi

etcfld="/etc/firewall.tester"
optfld="/opt/firewall.tester"
usrbin="/usr/sbin/firewall.tester"

rm -rf $usrbin
rm -rf $optfld
rm -rf $etcfld

rm -rf /var/log/firewall.tester.log

tmpcron=`mktemp`
crontab -l | grep -v firewall.tester > $tmpcron
crontab $tmpcron
rm -rf $tmpcron

exit 0
