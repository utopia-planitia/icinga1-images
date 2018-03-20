FROM ubuntu:17.10 AS icinga

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install --no-install-recommends less sudo procps ca-certificates wget pwgen && \
    apt-get -qqy install --no-install-recommends supervisor && \
    apt-get -qqy --no-install-recommends install apache2 dnsutils && \
    apt-get -qqy install --no-install-recommends icinga icinga-doc nagios-plugins nagios-nrpe-plugin && \
    rm -rf /var/lib/apt/lists/* && \
    gpasswd -a www-data nagios

EXPOSE 80
VOLUME /etc/icinga
VOLUME /var/log/icinga
VOLUME /var/cache/icinga

COPY icinga/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY icinga/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

RUN mv /etc/icinga/stylesheets /usr/share/icinga/htdocs/stylesheets
COPY icinga/apache-icinga.conf /etc/apache2/conf-enabled/icinga.conf
COPY icinga/000-default.conf  /etc/apache2/sites-available/000-default.conf

RUN sed -i "s,check_external_commands=0,check_external_commands=1," /etc/icinga/icinga.cfg
RUN sed -i 's/#default_user_name=guest/default_user_name=icingaadmin/g' /etc/icinga/cgi.cfg



FROM icinga AS plugins

RUN apt-get update && \
    apt-get -y install --no-install-recommends curl nmap nano libcache-memcached-perl postgresql-client ceph-common && \
    rm -rf /var/lib/apt/lists/* && \
    gpasswd -a www-data nagios

# memcache check
# from http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=3609&cf_id=24
COPY plugins/check_memcached.pl /usr/lib/nagios/plugins/check_memcached.pl
RUN chmod +x /usr/lib/nagios/plugins/check_memcached.pl

# postgres check
# from https://exchange.nagios.org/directory/Plugins/Databases/PostgresQL/check_postgres/details
COPY plugins/check_postgres.pl /usr/lib/nagios/plugins/check_postgres.pl
RUN chmod +x /usr/lib/nagios/plugins/check_postgres.pl

# port closed check
# from http://anonscm.debian.org/cgit/mirror/dsa-nagios.git/plain/dsa-nagios-checks/checks/dsa-check-port-closed
COPY plugins/dsa-check-port-closed /usr/lib/nagios/plugins/check_port_closed
RUN chmod +x /usr/lib/nagios/plugins/check_port_closed

# etcd
COPY plugins/check_etcd /usr/lib/nagios/plugins/check_etcd
RUN chmod +x /usr/lib/nagios/plugins/check_etcd
RUN mkdir -p /etc/etcd/cert/

# kubectl
RUN curl -o /usr/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl
ADD plugins/check_kubectl /usr/lib/nagios/plugins/check_kubectl
RUN chmod +x /usr/lib/nagios/plugins/check_kubectl

# cephfs
COPY plugins/ceph/check_ceph_health /usr/lib/nagios/plugins/check_ceph_health
COPY plugins/ceph/check_ceph_mon /usr/lib/nagios/plugins/check_ceph_mon
COPY plugins/ceph/check_ceph_osd /usr/lib/nagios/plugins/check_ceph_osd
COPY plugins/ceph/check_ceph_rgw /usr/lib/nagios/plugins/check_ceph_rgw
COPY plugins/ceph/check_ceph_mds /usr/lib/nagios/plugins/check_ceph_mds
RUN chmod +x /usr/lib/nagios/plugins/check_ceph_*
