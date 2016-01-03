FROM ubuntu:15.10

# Dpkg configuration
ENV DEBIAN_FRONTEND noninteractive

# Update package lists.
RUN apt-get -qq update

# Install basic packages.
RUN apt-get -qqy install --no-install-recommends less sudo procps ca-certificates wget pwgen

# Install supervisord because we need to run Apache and Icinga at the same time.
RUN apt-get -qqy install --no-install-recommends supervisor

# Add supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# When depencencies are pulled in by icinga, they seem to be configured too late and configuration
# of icinga fails. To work around this, install dependencies beforehand.
RUN apt-get -qqy --no-install-recommends install apache2 dnsutils

# Install icinga
RUN apt-get -qqy install --no-install-recommends icinga icinga-docs nagios-plugins nagios-nrpe-plugin

RUN gpasswd -a www-data nagios
RUN chown -R nagios:www-data /var/lib/icinga/rw
RUN chmod g+rwxs /var/lib/icinga/rw

EXPOSE 80

# Initialize and run Supervisor
CMD ["/usr/bin/supervisord"]
