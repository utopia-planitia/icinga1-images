# Alerting Images

Generic Docker images to deploy a [icinga](https://github.com/Icinga/icinga-core) server and icinga clients.

Icinag is based on [nagios](https://www.nagios.org/). Plugins for Nagios should work for icinga.

## Usage

deploy these images to kubernetes and configure via a configmap.

## Volumes

| Path | Purpose |
| --- | --- |
| /etc/icinga | Icinga configuration files |
| /var/cache/icinga | Icinga state retention and cache files |
