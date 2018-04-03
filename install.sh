#!/bin/bash

# svirepunchik@gmail.com (c) 2018
# firewall test script installer

iam=`whoami`

if [[ $iam != "root" ]]; then echo "you must be root. please run sudo ./install.sh"; exit 1; fi

etcfld="/etc/firewall.tester"
optfld="/opt/firewall.tester"
usrbin="/usr/sbin/firewall.tester"

cp -rp ./etc /
cp -rp ./opt /
cp -rp ./README.md $etcfld
cp -rp ./LICENCE $etcfld

chmod -R a+x $optfld
chmod -R a+r $etcfld

mkdir -p /var/log
touch /var/log/firewall.scan.log

rm -rf $usrbin
ln -s $optfld/firewall.tester.sh $usrbin

tmpcron=`mktemp`
crontab -l > $tmpcron
echo "0 22 * * * $usrbin -b" >> $tmpcron
crontab $tmpcron
rm -rf $tmpcron

echo "installed. run firewall.tester -h"

exit 0
