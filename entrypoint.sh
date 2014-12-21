#!/bin/bash
set -e 

gpasswd -a www-data nagios
rm -rf /var/lib/icinga/rw
mkdir -p /var/lib/icinga/rw
chown -R nagios:www-data /var/lib/icinga/rw
chmod g+rwxs /var/lib/icinga/rw
exec "$@"
