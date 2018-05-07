# firewall test script
## In English:
firewall-tester — NMAP-based bash script for testing target server or a set of servers for an unnesessary opened ports.

In normal mode it takes target server name (or server IP) and a list of allowed ports. The result is a list of opened ports, excluding the allowed. This allows you to know if target server containts unnesessary opened ports. 

### Dependecies
1. grep
2. sed
3. nmap

On each launch script checks dependencies.

### Installation
1. download
2. run `./install.sh`
3. enjoy

For batch mode please check:
1. your `/etc/firewall-tester/server.list`
2. your cron if you want to use batch mode (installer creates a file `/etc/cron.daily/firewall-tester`)
3. your logrotate

### Options
```
-h                              — displays short help.
-s <server name or IP>          — sets target server. Default is 127.0.0.1.
-a "port1, port2, ..., portN"   — sets a list of allowed to be open ports for target server. Default is "22, 80, 443".
-l /path/to/log.file            — sets custom log file. Default is /var/log/firewall.scan.log.
-b                              — sets batch mode. In this mode list of target servers and their allowed ports is taken from /etc/firewall-tester/server.list. Default is OFF.
```
There are long options also similar to short:
```
--help      — equal to -h
--server    — equal to -s
--allowed   — equal to -a
--logfile   — equal to -l
--batch     — equal to -b
```

### Format of /etc/firewall-tester/server.list
```
server1 <tab> port1, port2, ..., portN
server2 <tab> port1, port2, ..., portN
...
serverN <tab> port1, port2, ..., portN
```
You can comment lines with `#`

### Hooks
Hooks are located in `/usr/share/firewall-tester`.

There are two files:

#### hook-server.sh
Hook is called when script detects at least one unnesessary opened port on target server. It receives three parameters:
1. server name (or server IP)
2. list of allowed ports
3. list of opened ports

#### hook-all.sh
Hook is called when script detects at lease one unnesessary opened port on al least one target server. It receives nothing.

## По-русски:
firewall-tester — bash-скрипт, использующий NMAP, для проверки открытых портов на стороннем сервере или по списку серверов.

В обычном режиме принимает на вход имя сервера (или его IP-адрес) и список разрешённых для сервера портов. На выходе будет выдан список открытых портов сервера с исключением разрешённых. Таким образом вы можете сразу узнать, что на целевом сервере есть несанкционированно открытые порты.

### Зависимости
1. grep
2. sed
3. nmap

При каждом запуске скрипт перепроверит наличие нужных утилит.

### Установка
1. скачиваем
2. запускаем `./install.sh`
3. радуемся

Для корректной работы batch режима проверьте:
1. ваш `/etc/firewall-tester/server.list`
2. ваш крон (инсталлятор создаёт `/etc/cron.daily/firewall-tester`)
3. ваш logrotate

### Опции запуска
```
-h                              — показывает help.
-s <server name or IP>          — указывает целевой сервер. По-умолчанию 127.0.0.1.
-a "port1, port2, ..., portN"   — указывает список разрешённых портов для целевого сервера. По-умолчанию "22, 80, 443".
-l /path/to/log.file            — указывает другой лог-файл. По-умолчанию /var/log/firewall.scan.log.
-b                              — запускает batch режим. В этом режиме список целевых серверов и их разрешённых портов берётся из /etc/firewall-tester/server.list. По-умолчанию выключен.
```
There are long options also similar to short:
```
--help      — то же, что и -h
--server    — то же, что и -s
--allowed   — то же, что и -a
--logfile   — то же, что и -l
--batch     — то же, что и -b
```

### Формат `/etc/firewall-tester/server.list`
```
server1 <tab> port1, port2, ..., portN
server2 <tab> port1, port2, ..., portN
...
serverN <tab> port1, port2, ..., portN
```
строки можно комментировать с `#`

### Хуки
Хуки расположены в `/usr/share/firewall-tester`.

В этой папке всего два файла:

#### hook-server.sh
Хук вызывается6 когда скрипт обнаруживает хотя бы один открытый порт на целевом сервере, который не входит в список разрешённых. Он получает на вход три параметра: 
1. имя сервера (или его ip)
2. список разрешённых для этого сервера портов
3. список открытых портов, за исключением разрешённых

#### hook-all.sh
Хук вызывается, когда скрипт обнаруживает хотябы один открытый порт хотя бы на одном целевом сервере. На вход он не получает ничего.
