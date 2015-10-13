#!/bin/bash

touch /etc/apache2/apache.pid
unlink /etc/apache2/apache.pid

if [ ! -f /etc/nagios3/htpasswd.users ] ; then
  htpasswd -c -b -s /etc/nagios3/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
  chown -R nagios.nagios /etc/nagios3/htpasswd.users
fi

rm -r /var/lib/nagios3
rm -r /var/cache/nagios3
#rmdir /tmp
mkdir /dev/shm/var-lib-nagios3
mkdir /dev/shm/var-cache-nagios3
#mkdir /dev/shm/tmp
ln -s /dev/shm/var-lib-nagios3 /var/lib/nagios3
ln -s /dev/shm/var-cache-nagios3 /var/cache/nagios3
#ln -s /dev/shm/tmp /tmp

mkdir /var/lib/nagios3/rw
mkdir /var/lib/nagios3/spool
mkdir /var/lib/nagios3/spool/checkresults

#chmod 6777 /dev/shm/tmp
chown nagios. -R /dev/shm/var-lib-nagios3
chown nagios. -R /dev/shm/var-cache-nagios3

exec runsvdir /etc/sv
