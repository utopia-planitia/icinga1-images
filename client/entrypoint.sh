#!/bin/bash
set -uexo pipefail

# fix detection of mounts
test -f /etc/mtab && rm -f /etc/mtab
ln -s /proc/mounts /etc/mtab

# prepare config
mkdir -p /etc/nagios
cp /etc/nagios-mount/nrpe.cfg /etc/nagios/nrpe.cfg
export NETWORK_DEVICE_NAME=$(ip r | grep -w 'default via' | awk '{ print $5 }')
cat /etc/nagios-mount/nrpe_local.cfg | envsubst > /etc/nagios/nrpe_local.cfg

# run nrpe server
usr/sbin/nrpe -c /etc/nagios/nrpe.cfg -f
