#!/bin/bash

# svirepunchik@gmail.com (c) 2018
# firewall test script uninstaller

iam=`whoami`

if [[ $iam != "root" ]]; then echo "you must be root. please run sudo ./uninstall.sh"; exit 1; fi

etcfld="/etc/firewall-tester"
usrbin="/usr/bin/firewall-tester"
hookfld="/usr/share/firewall-tester"
docfld="/usr/share/doc/firewall-tester"
man1="/usr/share/man/man1/firewall-tester.1.gz"
man1ru="/usr/share/man/ru/man1/firewall-tester.1.gz"
cron="/etc/cron.daily/firewall-tester"
lr="/etc/logrotate.d/firewall-tester"

rm -rf $etcfld
rm -rf $usrbin
rm -rf $hookfld
rm -rf $docfld
rm -rf $man1
rm -rf $man1ru
rm -rf $cron
rm -rf $lr
rm -rf /var/log/firewall.scan.log

tmpcron=`mktemp`
crontab -l | grep -v firewall-tester > $tmpcron
crontab $tmpcron
rm -rf $tmpcron

echo "uninstalled."

exit 0
