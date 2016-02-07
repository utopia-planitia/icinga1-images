#!/bin/bash

rm -r /var/lib/icinga
mkdir /dev/shm/var-lib-nagios3
ln -s /dev/shm/var-lib-nagios3 /var/lib/nagios3

mkdir /var/lib/nagios3/rw
mkdir /var/lib/nagios3/spool
mkdir /var/lib/nagios3/spool/checkresults

chown nagios. -R /dev/shm/var-lib-nagios3
