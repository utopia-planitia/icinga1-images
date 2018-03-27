FROM lachlanevenson/k8s-kubectl:v1.9.6 AS kubectl

FROM ubuntu:17.10
COPY --from=kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        less sudo procps ca-certificates wget pwgen \
        supervisor \
        apache2 dnsutils \
        icinga icinga-doc nagios-plugins nagios-nrpe-plugin \
        curl nano \
        sudo && \
    rm -rf /var/lib/apt/lists/* && \
    gpasswd -a www-data nagios

EXPOSE 80

COPY icinga/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY icinga/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

RUN mv /etc/icinga/stylesheets /usr/share/icinga/htdocs/stylesheets
COPY icinga/apache-icinga.conf /etc/apache2/conf-enabled/icinga.conf
COPY icinga/000-default.conf  /etc/apache2/sites-available/000-default.conf

RUN sed -i 's/check_external_commands=0/check_external_commands=1/g' /etc/icinga/icinga.cfg
RUN sed -i 's/#default_user_name=guest/default_user_name=icingaadmin/g' /etc/icinga/cgi.cfg

RUN echo "nagios          ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/" >> /etc/sudoers

RUN apt-get update && \
    apt-get -y install --no-install-recommends nmap ceph-common && \
    rm -rf /var/lib/apt/lists/* && \
    gpasswd -a www-data nagios

# port closed check
# from http://anonscm.debian.org/cgit/mirror/dsa-nagios.git/plain/dsa-nagios-checks/checks/dsa-check-port-closed
COPY plugins/dsa-check-port-closed /usr/lib/nagios/plugins/check_port_closed
RUN chmod +x /usr/lib/nagios/plugins/check_port_closed

# kubernetes
COPY plugins/check_kubernetes          /usr/lib/nagios/plugins/
COPY plugins/check_kubernetes.cfg      /etc/nagios-plugins/config/
COPY plugins/check_pods                /usr/lib/nagios/plugins/
COPY plugins/check_pods.cfg            /etc/nagios-plugins/config/
COPY plugins/check_ssl_certificate     /usr/lib/nagios/plugins/
COPY plugins/check_ssl_certificate.cfg /etc/nagios-plugins/config/

# cephfs
COPY plugins/ceph/check_ceph_health /usr/lib/nagios/plugins/check_ceph_health
COPY plugins/ceph/check_ceph_mon /usr/lib/nagios/plugins/check_ceph_mon
COPY plugins/ceph/check_ceph_osd /usr/lib/nagios/plugins/check_ceph_osd
COPY plugins/ceph/check_ceph_rgw /usr/lib/nagios/plugins/check_ceph_rgw
COPY plugins/ceph/check_ceph_mds /usr/lib/nagios/plugins/check_ceph_mds
RUN chmod +x /usr/lib/nagios/plugins/check_ceph_*

RUN rm -rf /etc/icinga/objects
COPY objects /etc/icinga/objects

COPY ssl /ssl

COPY plugins/check_nrpe.cfg       /etc/nagios-plugins/config/
