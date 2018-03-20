FROM registry.suchgenie.de/platform/icinga:40cf93060f71196339399770df50a26eb787d09a

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

# port closed check
# from http://anonscm.debian.org/cgit/mirror/dsa-nagios.git/plain/dsa-nagios-checks/checks/dsa-check-port-closed
ADD dsa-check-port-closed /usr/lib/nagios/plugins/check_port_closed
RUN chmod +x /usr/lib/nagios/plugins/check_port_closed

# etcd
COPY check_etcd /usr/lib/nagios/plugins/check_etcd
RUN chmod +x /usr/lib/nagios/plugins/check_etcd
RUN mkdir -p /etc/etcd/cert/

# kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl /usr/bin/kubectl
RUN chmod +x /usr/bin/kubectl
ADD check_kubectl /usr/lib/nagios/plugins/check_kubectl
RUN chmod +x /usr/lib/nagios/plugins/check_kubectl

# cephfs
RUN apt-get install -qqy ceph-common
COPY ceph/check_ceph_health /usr/lib/nagios/plugins/check_ceph_health
COPY ceph/check_ceph_mon /usr/lib/nagios/plugins/check_ceph_mon
COPY ceph/check_ceph_osd /usr/lib/nagios/plugins/check_ceph_osd
COPY ceph/check_ceph_rgw /usr/lib/nagios/plugins/check_ceph_rgw
COPY ceph/check_ceph_mds /usr/lib/nagios/plugins/check_ceph_mds
RUN chmod +x /usr/lib/nagios/plugins/check_ceph_*
