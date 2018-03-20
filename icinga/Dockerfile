FROM ubuntu:17.10

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

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

COPY apache-icinga.conf /etc/apache2/conf-enabled/icinga.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN ln -s /etc/icinga/stylesheets /usr/share/icinga/htdocs/stylesheets

RUN sed -i "s,check_external_commands=0,check_external_commands=1," /etc/icinga/icinga.cfg
RUN sed -i 's/#default_user_name=guest/default_user_name=icingaadmin/g' /etc/icinga/cgi.cfg
