#!/bin/bash

gpasswd -a www-data nagios

rm -r /var/lib/icinga
mkdir /dev/shm/var-lib-icinga
ln -s /dev/shm/var-lib-icinga /var/lib/icinga

rm -r /var/cache/icinga
mkdir /dev/shm/var-cache-icinga
ln -s /dev/shm/var-cache-icinga /var/cache/icinga

mkdir /var/lib/icinga/rw
mkdir /var/lib/icinga/spool
mkdir /var/lib/icinga/spool/checkresults

chown nagios:www-data -R /dev/shm/var-lib-icinga
chown nagios:www-data -R /dev/shm/var-cache-icinga

chown nagios:www-data -R /var/lib/icinga
chmod g+rwxs /var/lib/icinga/rw
chown nagios:www-data -R /var/cache/icinga

mkdir /var/log/icinga/archives/
chown nagios:www-data -R /var/log/icinga/archives/

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
