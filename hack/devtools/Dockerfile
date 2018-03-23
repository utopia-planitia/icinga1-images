FROM ubuntu:17.10

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        openssl && \
    rm -rf /var/lib/apt/lists/*