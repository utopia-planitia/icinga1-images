#!/bin/bash
set -e 

gpasswd -a www-data nagios
rm -rf /var/lib/icinga/rw
mkdir -p                 /var/lib/icinga/rw
chown -R nagios:www-data /var/lib/icinga/rw
chmod -R g+rwxs          /var/lib/icinga/rw
touch                    /var/log/icinga/icinga.log
chown -R nagios:www-data /var/log/icinga
chmod -R g+rwxs          /var/log/icinga
chmod -R o+rwx           /var/log/icinga

if [ "$@" == "" ]; then
    /usr/sbin/icinga /etc/icinga/icinga.cfg -v
fi

exec "$@"