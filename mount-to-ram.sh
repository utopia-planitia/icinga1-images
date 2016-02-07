#!/bin/bash

rm -r /var/lib/icinga
mkdir /dev/shm/var-lib-icinga
ln -s /dev/shm/var-lib-icinga /var/lib/icinga

mkdir /var/lib/icinga/rw
mkdir /var/lib/icinga/spool
mkdir /var/lib/icinga/spool/checkresults

chown nagios. -R /dev/shm/var-lib-icinga

/usr/bin/supervisord
