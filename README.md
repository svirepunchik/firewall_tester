# firewall test script
## In English:
comnig soon

## По-русски:
В последнее время стало мне доставаться на поддержку много серверов от, мягко говоря, странных админов. Суть в том, что (ОКАЗЫВАЕТСЯ) многие админы не следят за сетевой безопасностью вверенных им серверов — и вроде в фаерволе даже правила есть, и вроде даже fail2ban настроен на защиту 22го порта, НО... При детальном осмотре, как правило, выясняется две вещи:
1. Несмотря на наличие правил в фаерволе, цепочка INPUT стоит в ACCEPT;
2. fail2ban установлен, но не настроено никакое действие в нём.

Это жопа, товарищи!

Чтобы не вчитываться личшний раз в конфиги, я решил написать скрипт, который без лишнего геморроя будет сообщать, какие из портов на целевых серверах открыты, кроме портов, которые задуманы. Это удобно, чтобы понять, где настройщик фаервола ошибся.
Конфиг серверов и положенных им открытых наружу портов лежит в файле `/etc/firewall.tester/servers.list`.

### Зависимости
То, без чего скрипт работать не будет:
1. bash ;)
2. grep
3. sed
4. awk
5. nmap (!)

При каждом запуске скрипт перепроверит наличие нужных утилит.

### Установка
Всё очень просто и прозрачно — клонируемся, запускаем install.sh и радуемся. Логи глядим в `/var/log/firewall.scan.log`.
install.sh сам создаст в cron задачу по мониторингу серверов из списка `/etc/firewall.tester/server.list`.

### Batch-режим
Формат server.list:
`server_ip | server_name [tab] allowed_port_1,allowed_port_2,...,allowed_port_N`
строки можно комментировать с `#`

После того, как вы заполнили server.list, задача в cron будет сама мониторить все сервера из списка, писать в лог и вызывать хуки.

### Хуки
Возможно, вы захотите использовать хуки. Например, в режиме мониторигна по cron отправлять в мессенджер сообщение о том, что какой-то сервер открыл лишний порт.

`hook.server.sh` — хук, вызываемый для каждого сервера, в том числе в batch режиме; в скрипт передаётся адрес сервера, список разрешённых портов, список неразрешённых открытых портов.

`hook.all.sh` — хук, вызываемый после обработки всех серверов только в batch режиме; в скрпит ничего не передаётся.

### Внимание! Конфиг для `logrotate` не устанавливается по-умолчанию
Это связано с тем, что продукт может использоваться на MacOS, а где там logrotate и как он настраивается я пока не знаю.

Вот вам типовой для линукса:
```
/var/log/firewall.scan.log {
    copytruncate
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
}
```
