# Volumes

This container exposes these volumes:

```
/etc/icinga       --> Icinga configuration files
/var/cache/icinga --> Icinga state retention and cache files
```

# Setting passwords

There are no users defined, so you have to set a password before you can log into Icinga's web interface:


```
htpasswd -c /path/to/etc/icinga/volume/htpasswd.users icingaadmin
```

