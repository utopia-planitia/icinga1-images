FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        less sudo procps ca-certificates wget pwgen \
        supervisor \
        apache2 dnsutils \
        icinga icinga-doc nagios-plugins nagios-nrpe-plugin \
        curl nano \
        bc \
        jq \
        sudo && \
    rm -rf /var/lib/apt/lists/* && \
    gpasswd -a www-data nagios

RUN curl -L -o /usr/local/bin/kubectl --fail https://storage.googleapis.com/kubernetes-release/release/v1.17.2/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

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

# port closed check
# from http://anonscm.debian.org/cgit/mirror/dsa-nagios.git/plain/dsa-nagios-checks/checks/dsa-check-port-closed
COPY plugins/dsa-check-port-closed /usr/lib/nagios/plugins/check_port_closed
RUN chmod +x /usr/lib/nagios/plugins/check_port_closed

# plugins
COPY plugins/check_nrpe.cfg            /etc/nagios-plugins/config/
COPY plugins/check_kubernetes          /usr/lib/nagios/plugins/
COPY plugins/check_pods                /usr/lib/nagios/plugins/
COPY plugins/check_pods.cfg            /etc/nagios-plugins/config/
COPY plugins/check_ssl_certificate     /usr/lib/nagios/plugins/
COPY plugins/check_ssl_certificate.cfg /etc/nagios-plugins/config/
COPY plugins/check_ceph                /usr/lib/nagios/plugins/
COPY plugins/check_rook                /usr/lib/nagios/plugins/
