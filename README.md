# About This Image

1. Based on ubuntu:trusty
1. Contains Postfix to be able to send emails.
1. Contains rsyslogd to be able to read postfix's log entries.
1. No SSH. If you need to execute commands in the context of the container, you can use [nsenter](https://github.com/jpetazzo/nsenter).
1. No database. IDO is not configured.

# How To Use This Image

Start the Icinga container.

```
docker run -dt jeyk/icinga
```

# Volumes

This container exposes these volumes:

```
/etc/icinga       --> Icinga configuration files
/var/cache/icinga --> Icinga state retention and cache files
```

# Setting passwords

There are no users defined, so you have to set a password before you can log into Icinga's web interface:


```
htpasswd -c /path/to/volume/htpasswd.users icingaadmin
```

