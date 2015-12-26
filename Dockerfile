FROM ubuntu:14.04

# apt config
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN sed -i 's/universe/universe multiverse/' /etc/apt/sources.list

# install nagios
RUN apt-get install -y nagios3 nagios-nrpe-plugin runit

RUN apt-get install -y curl nmap nano

# set apache path
RUN sed -i.bak 's/.*\=www\-data//g' /etc/apache2/envvars
RUN export DOC_ROOT="DocumentRoot /usr/share/nagios3/htdocs"; sed -i "s,DocumentRoot.*,$DOC_ROOT," /etc/apache2/sites-enabled/000-default.conf

# memcache check
# from http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=3609&cf_id=24 
ADD check_memcached.pl /usr/lib/nagios/plugins/check_memcached.pl
RUN chmod +x /usr/lib/nagios/plugins/check_memcached.pl
RUN apt-get install -y libcache-memcached-perl

# postgres check
# from https://exchange.nagios.org/directory/Plugins/Databases/PostgresQL/check_postgres/details
ADD check_postgres.pl /usr/lib/nagios/plugins/check_postgres.pl
RUN chmod +x /usr/lib/nagios/plugins/check_postgres.pl
RUN apt-get install -y postgresql-client

# zookeeper check
# from https://raw.githubusercontent.com/harisekhon/nagios-plugins/master/check_zookeeper.pl 
ADD check_zookeeper.pl /usr/lib/nagios/plugins/check_zookeeper.pl
RUN chmod +x /usr/lib/nagios/plugins/check_zookeeper.pl
ADD harisekhon /usr/lib/nagios/plugins/lib/
RUN rm -r /usr/lib/nagios/plugins/lib/.git /usr/lib/nagios/plugins/lib/.travis.yml /usr/lib/nagios/plugins/lib/.gitignore /usr/lib/nagios/plugins/lib/t
RUN apt-get install -y libjson-perl libterm-readkey-perl libmath-round-perl

# port closed check
# from http://anonscm.debian.org/cgit/mirror/dsa-nagios.git/plain/dsa-nagios-checks/checks/dsa-check-port-closed
ADD dsa-check-port-closed /usr/lib/nagios/plugins/check_port_closed
RUN chmod +x /usr/lib/nagios/plugins/check_port_closed

# startup
RUN mkdir -p /etc/sv/nagios && mkdir -p /etc/sv/apache && rm -rf /etc/sv/getty-5 && mkdir -p /etc/sv/postfix
ADD nagios.init /etc/sv/nagios/run
ADD apache.init /etc/sv/apache/run
ADD postfix.init /etc/sv/postfix/run
ADD postfix.stop /etc/sv/postfix/finish

# control access
COPY htpasswd.users /etc/nagios3/htpasswd.users
RUN cd /usr/share/nagios3/htdocs/ && ln -s /etc/nagios3/stylesheets/ .

RUN sed -i "s,check_external_commands=0,check_external_commands=1," /etc/nagios3/nagios.cfg

ENV APACHE_LOCK_DIR /var/run
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE apache.pid
ENV APACHE_RUN_USER nagios
ENV APACHE_RUN_GROUP nagios

EXPOSE 80

RUN rm -rf /etc/nagios3/conf.d/*

#VOLUME /var/lib/nagios3/
VOLUME /etc/nagios3/conf.d/

ADD start.sh /usr/local/bin/start_nagios
CMD ["/usr/local/bin/start_nagios"]
