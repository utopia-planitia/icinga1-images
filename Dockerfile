FROM registry.suchgenie.de/icinga:f9da28d52c356e4cd32fc2f30c9bc2ed6e7f8d8f

ENV RESET_BUILD_CACHE 2016-02-07
RUN apt-get -qq update

RUN apt-get install -qqy curl nmap nano

# memcache check
# from http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=3609&cf_id=24 
ADD check_memcached.pl /usr/lib/nagios/plugins/check_memcached.pl
RUN chmod +x /usr/lib/nagios/plugins/check_memcached.pl
RUN apt-get install -qqy libcache-memcached-perl

# postgres check
# from https://exchange.nagios.org/directory/Plugins/Databases/PostgresQL/check_postgres/details
ADD check_postgres.pl /usr/lib/nagios/plugins/check_postgres.pl
RUN chmod +x /usr/lib/nagios/plugins/check_postgres.pl
RUN apt-get install -qqy postgresql-client

# zookeeper check
# from https://raw.githubusercontent.com/harisekhon/nagios-plugins/master/check_zookeeper.pl 
ADD check_zookeeper.pl /usr/lib/nagios/plugins/check_zookeeper.pl
RUN chmod +x /usr/lib/nagios/plugins/check_zookeeper.pl
ADD harisekhon /usr/lib/nagios/plugins/lib/
RUN rm -r /usr/lib/nagios/plugins/lib/.git /usr/lib/nagios/plugins/lib/.travis.yml /usr/lib/nagios/plugins/lib/.gitignore /usr/lib/nagios/plugins/lib/t
RUN apt-get install -qqy libjson-perl libterm-readkey-perl libmath-round-perl

# port closed check
# from http://anonscm.debian.org/cgit/mirror/dsa-nagios.git/plain/dsa-nagios-checks/checks/dsa-check-port-closed
ADD dsa-check-port-closed /usr/lib/nagios/plugins/check_port_closed
RUN chmod +x /usr/lib/nagios/plugins/check_port_closed

# etcd
COPY check_etcd /usr/lib/nagios/plugins/check_etcd
RUN chmod +x /usr/lib/nagios/plugins/check_etcd
RUN mkdir -p /etc/etcd/cert/

# kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/v1.1.3/bin/linux/amd64/kubectl /usr/bin/kubectl
RUN chmod +x /usr/bin/kubectl
ADD check_kubectl /usr/lib/nagios/plugins/check_kubectl
RUN chmod +x /usr/lib/nagios/plugins/check_kubectl

# cephfs
RUN apt-get install -qqy ceph-common
COPY ceph/check_ceph_health /usr/lib/nagios/plugins/check_ceph_health
COPY ceph/check_ceph_mon /usr/lib/nagios/plugins/check_ceph_mon
COPY ceph/check_ceph_osd /usr/lib/nagios/plugins/check_ceph_osd
COPY ceph/check_ceph_rgw /usr/lib/nagios/plugins/check_ceph_rgw
RUN chmod +x /usr/lib/nagios/plugins/check_ceph_*
RUN mkdir /etc/ceph
