FROM ubuntu:14.04

# apt config
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN sed -i 's/universe/universe multiverse/' /etc/apt/sources.list

# cassandra source
COPY apache-cassandra.list /etc/apt/sources.list.d/apache-cassandra.list
RUN gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D && gpg --export --armor F758CE318D77295D | apt-key add -
RUN gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00 && gpg --export --armor 2B5C1B00 | apt-key add -
RUN gpg --keyserver pgp.mit.edu --recv-keys 0353B12C && gpg --export --armor 0353B12C | apt-key add -

# update system
RUN apt-get update
RUN apt-get upgrade -y

# install nagios
RUN apt-get install -y nagios3 nagios-nrpe-plugin runit

# set apache path
RUN sed -i.bak 's/.*\=www\-data//g' /etc/apache2/envvars
RUN export DOC_ROOT="DocumentRoot /usr/share/nagios3/htdocs"; sed -i "s,DocumentRoot.*,$DOC_ROOT," /etc/apache2/sites-enabled/000-default.conf

# cassandra check
# from http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=3072&cf_id=24
ADD cass_unreachable_nodes /usr/lib/nagios/plugins/cass_unreachable_nodes
RUN apt-get install -y cassandra-tools

# memcache check
# from http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=3609&cf_id=24 
ADD check_memcached.pl /usr/lib/nagios/plugins/check_memcached.pl
RUN apt-get install -y libcache-memcached-perl

# zookeeper check
# from https://raw.githubusercontent.com/harisekhon/nagios-plugins/master/check_zookeeper.pl 
ADD check_zookeeper.pl /usr/lib/nagios/plugins/check_zookeeper.pl

# startup
RUN mkdir -p /etc/sv/nagios && mkdir -p /etc/sv/apache && rm -rf /etc/sv/getty-5 && mkdir -p /etc/sv/postfix
ADD nagios.init /etc/sv/nagios/run
ADD apache.init /etc/sv/apache/run
ADD postfix.init /etc/sv/postfix/run
ADD postfix.stop /etc/sv/postfix/finish

# control access
COPY htpasswd.users /etc/nagios3/htpasswd.users
RUN cd /usr/share/nagios3/htdocs/ && ln -s /etc/nagios3/stylesheets/ .

ENV APACHE_LOCK_DIR /var/run
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE apache.pid
ENV APACHE_RUN_USER nagios
ENV APACHE_RUN_GROUP nagios

EXPOSE 80

VOLUME /var/lib/nagios3/
VOLUME /etc/nagios3/conf.d/

ADD start.sh /usr/local/bin/start_nagios
CMD ["/usr/local/bin/start_nagios"]
