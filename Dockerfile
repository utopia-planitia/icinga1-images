FROM ubuntu:15.10

# Dpkg configuration
ENV DEBIAN_FRONTEND noninteractive

# Update package lists.
ENV RESET_BUILD_CACHE 2016-02-07
RUN apt-get -qq update

# Install basic packages.
RUN apt-get -qqy install --no-install-recommends less sudo procps ca-certificates wget pwgen

# Install supervisord because we need to run Apache and Icinga at the same time.
RUN apt-get -qqy install --no-install-recommends supervisor

# When depencencies are pulled in by icinga, they seem to be configured too late and configuration
# of icinga fails. To work around this, install dependencies beforehand.
RUN apt-get -qqy --no-install-recommends install apache2 dnsutils

# Install icinga
RUN apt-get -qqy install --no-install-recommends icinga icinga-doc nagios-plugins nagios-nrpe-plugin

EXPOSE 80

Volume /var/log/icinga

COPY apache-icinga.conf /etc/apache2/conf-enabled/icinga.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN ln -s /etc/icinga/stylesheets /usr/share/icinga/htdocs/stylesheets

RUN sed -i "s,check_external_commands=0,check_external_commands=1," /etc/icinga/icinga.cfg
RUN sed -i 's/#default_user_name=guest/default_user_name=icingaadmin/g' /etc/icinga/cgi.cfg

# Add supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
CMD ["/startup.sh"]
