#!/bin/bash

# svirepunchik@gmail.com (c) 2018
# firewall test script installer

iam=`whoami`

if [[ $iam != "root" ]]; then echo "you must be root. please run sudo ./install.sh"; exit 1; fi

cp -rp ./etc /
cp -rp ./usr /

chmod -R a+x /usr/bin/firewall-tester
chmod -R a+x /usr/share/firewall-tester/*.sh
chmod -R a+r /etc/firewall-tester

mkdir -p /var/log
touch /var/log/firewall.scan.log

tmpcron=`mktemp`
crontab -l > $tmpcron
echo "0 22 * * * /usr/bin/firewall-tester -b" >> $tmpcron
crontab $tmpcron
rm -rf $tmpcron

echo "installed. run firewall.tester -h"

exit 0
