#!/bin/bash

# svirepunchik@gmail.com (c) 2018
# firewall test script
# dependencies: nmap, tee, awk, sed, grep

OPTS=`getopt -o hsalb: --long help,server,allowed,logfile,batch: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

usage="$(basename "$0") [-h] [-s server_name|server_ip] [-a \"allowed_port1, allowed_port2, ..., allowed_port n\"] [-l /path/to/log.file]
this script scans all the server ports
where:
    -h | --help     show this help text
    -s | --server   set server name or server ip (default is 127.0.0.1)
    -a | --allowed  set allowed ports in  (default is 22,80,443)
    -l | --logfile  set log file location (default is /var/log/firewall.scan.log)
    -b | --batch    set batch mode, script will use server.list and will ignore -s and -a options"

server="127.0.0.1"
allowed="22,80,443"
logfile="/var/log/firewall.scan.log"

nmapbin=`which nmap`
if [[ $? != 0 ]]; then echo "NMAP is not found. Please install NMAP."; exit 1; fi

teebin=`which tee`
if [[ $? != 0 ]]; then echo "TEE is not found. Please install TEE."; exit 1; fi

awkbin=`which awk`
if [[ $? != 0 ]]; then echo "AWK is not found. Please install AWK."; exit 1; fi

grepbin=`which grep`
if [[ $? != 0 ]]; then echo "GREP is not found. Please install GREP."; exit 1; fi

sedbin=`which sed`
if [[ $? != 0 ]]; then echo "SED is not found. Please install SED."; exit 1; fi

while true; do
  case $1 in
    -h | --help ) echo "$usage"; exit ;;
    -s | --server ) server="$2"; shift; shift ;;
    -a | --allowed ) allowed="$2"; shift; shift ;;
    -l | --logfile ) logfile="$2"; shift; shift ;;
    -b | --batch ) batch=true; shift ;;
    -- ) shift; break ;;
    * )  if [ -z "$1" ]; then break; else echo ""; echo "$1 is not a valid option"; echo ""; echo "$usage"; exit 1; fi;;
  esac
done

if [[ ! -e $logfile ]]; then touch $logfile; fi
if [[ ! -w $logfile || $? -ne 0 ]]; then echo "log file $logfile is not writeable or cant create log file!"; exit 1; fi

function check_server () {
    if [[ -z "$1" ]]; then echo "server not found" exit; else SERVER=$1; fi
    if [[ -z "$2" ]]; then ALLOWED="none"; else ALLOWED=$2; fi

    echo $(date +"%Y.%m.%d %H:%M:%S") - scanning server $SERVER. allowed ports: $ALLOWED | $teebin -a $logfile
    NMAPTMP=`mktemp`
    if [[ $? -ne 0 ]]; then echo "cant create temp file."; exit 1; fi
    $nmapbin -r -vvvvvvv -p 1-800 --max-retries 1 -n $SERVER 1&> $NMAPTMP

    ALLOWEDGREP=`echo $ALLOWED | $sedbin -e 's/ *, */\\\|/g'`
    OPENPORTS=`$grepbin -e '.*open.[^port]' $NMAPTMP | $grepbin -v "$ALLOWEDGREP"`

    rm -rf $nmaptmp

    if [[ -n "$OPENPORTS" ]]; then
        echo $(date +"%Y.%m.%d %H:%M:%S") - YOUR SERVER IS NOT SECURE | $teebin -a $logfile
        echo $(date +"%Y.%m.%d %H:%M:%S") - found open ports: | $teebin -a $logfile
        echo -e "PORT\tSTATE\tSERVICE\tREASON" | $teebin -a $logfile
        echo "$OPENPORTS" | $teebin -a $logfile
        return 1
    else
        echo $(date +"%Y.%m.%d %H:%M:%S") - server $SERVER has no unnesessary open ports | $teebin -a $logfile
        return 0
    fi
}

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
OPTDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
if [[ -f /etc/firewall.tester/server.list ]]; then ETCDIR="/etc/firewall.tester"; else ECTDIR=$OPTDIR; fi

if [[ $batch ]]
then
    if [[ ! -e $ETCDIR/server.list ]]; then echo $(date +"%Y.%m.%d %H:%M:%S") - $ETCDIR/server.list is not found. aborting | $teebin -a $logfile; exit 1; fi
    flag=0
    while read LINE; do
        if [[ -z "$LINE" ]]; then continue; fi
        declare $( echo $LINE | $awkbin '{print "bserver="$1; print "ballowed="$2;}' )
        check_server $bserver $ballowed
        if [[ $? != 0 ]]; then
            flag=1;
            if [[ -e $OPTDIR/hook.server.sh ]]; then
                echo $(date +"%Y.%m.%d %H:%M:%S") - calling per server hook | $teebin -a $logfile
                $OPTDIR/hook.server.sh "$bserver" "$ballowed" "$OPENPORTS"
            fi
        fi
    done < $ETCDIR/server.list
    if [[ $flag -eq 1 ]]; then
        if [[ -e $OPTDIR/hook.all.sh ]]; then
            echo $(date +"%Y.%m.%d %H:%M:%S") - calling common hook | $teebin -a $logfile
            $OPTDIR/hook.all.sh
        fi
    fi
else
    check_server $server $allowed
    if [[ $? != 0 ]]; then
        if [[ -e $OPTDIR/hook.server.sh ]]; then
            echo $(date +"%Y.%m.%d %H:%M:%S") - calling per server hook | $teebin -a $logfile
            $OPTDIR/hook.server.sh "$server" "$allowed" "$OPENPORTS"
        fi
    fi
fi
exit 0
