FROM docker:1.13.1 AS docker

FROM lachlanevenson/k8s-kubectl:v1.5.7 AS kubectl

FROM ubuntu:17.10
COPY --from=docker  /usr/local/bin/docker  /usr/local/bin/docker
COPY --from=kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install \
        nagios-nrpe-server \
        monitoring-plugins \
        curl \
        gcc python-dev python-pip smartmontools \
        sudo \
        lm-sensors \
        && \
    rm -rf /var/lib/apt/lists/*

COPY check_smartmon   /usr/lib/nagios/plugins/
RUN pip install psutil
COPY check_open_files /usr/lib/nagios/plugins/
COPY check_docker     /usr/lib/nagios/plugins/
COPY check_registry   /usr/lib/nagios/plugins/
COPY check_memory     /usr/lib/nagios/plugins/
COPY check_swap       /usr/lib/nagios/plugins/

EXPOSE 5666

RUN sed -i 's/#log_file=\/var\/log\/nrpe.log/log_file=\/var\/log\/nrpe.log/g' /etc/nagios/nrpe.cfg
RUN sed -i 's/allowed_hosts=127.0.0.1,::1/#allowed_hosts=127.0.0.1,::1/g' /etc/nagios/nrpe.cfg
RUN sed -i 's/pid_file=\/var\/run\/nagios\/nrpe.pid/#pid_file=\/var\/run\/nagios\/nrpe.pid/g' /etc/nagios/nrpe.cfg
#RUN sed -i 's/debug=0/debug=1/g' /etc/nagios/nrpe.cfg

RUN echo "nagios          ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/" >> /etc/sudoers
RUN sed -i 's/# command_prefix=\/usr\/bin\/sudo/command_prefix=\/usr\/bin\/sudo/g' /etc/nagios/nrpe.cfg

CMD ["/usr/sbin/nrpe", "-c", "/etc/nagios/nrpe.cfg", "-f"]

RUN sed -i 's/#ssl_cacert_file=\/etc\/ssl\/servercerts\/ca-cert.pem/ssl_cacert_file=\/ssl\/ca_cert.pem/g' /etc/nagios/nrpe.cfg
RUN sed -i 's/#ssl_cert_file=\/etc\/ssl\/servercerts\/nagios-cert.pem/ssl_cert_file=\/ssl\/client_cert.pem/g' /etc/nagios/nrpe.cfg
RUN sed -i 's/#ssl_privatekey_file=\/etc\/ssl\/servercerts\/nagios-key.pem/ssl_privatekey_file=\/ssl\/client_cert.key/g' /etc/nagios/nrpe.cfg
RUN sed -i 's/#ssl_client_certs=0/ssl_client_certs=2/g' /etc/nagios/nrpe.cfg

COPY ssl /ssl
COPY nrpe_local.cfg /etc/nagios/nrpe_local.cfg
