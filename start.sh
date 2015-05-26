#!/bin/bash

if [ ! -f /etc/nagios3/htpasswd.users ] ; then
  htpasswd -c -b -s /etc/nagios3/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}
  chown -R nagios.nagios /etc/nagios3/htpasswd.users
fi

exec runsvdir /etc/sv
