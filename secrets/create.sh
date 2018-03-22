#!/bin/bash

#https://support.nagios.com/kb/article.php?id=519

set -e

rm -r *.pem *.csr *.key demoCA ../client/ssl ../server/ssl || true
mkdir -p demoCA 
touch demoCA/index.txt
echo 1000 > demoCA/serial

openssl req -nodes -x509 -newkey rsa:4096 -keyout ca_key.pem -out ca_cert.pem -utf8 -days 3650 -subj "/C=DE/ST=BE/L=Berlin/O=SRE/OU=DEV/CN=OPS/"

openssl req -nodes -new -newkey rsa:2048 -keyout client_cert.key -out client_cert.csr -subj "/C=DE/ST=BE/L=Berlin/O=SRE/OU=DEV/CN=OPS/"
openssl ca -batch -outdir . -days 365 -notext -md sha256 -keyfile ca_key.pem -cert ca_cert.pem -in client_cert.csr -out client_cert.pem
mkdir -p ../client/ssl
cp ca_cert.pem client_cert.key client_cert.pem ../client/ssl

rm -r demoCA || true
mkdir -p demoCA 
touch demoCA/index.txt
echo 1001 > demoCA/serial


openssl req -nodes -new -newkey rsa:2048 -keyout nagios_server.key -out nagios_server.csr -subj "/C=DE/ST=BE/L=Berlin/O=SRE/OU=DEV/CN=OPS/"
openssl ca -batch -outdir . -days 365 -notext -md sha256 -keyfile ca_key.pem -cert ca_cert.pem -in nagios_server.csr -out nagios_server.pem
mkdir -p ../server/ssl 
cp ca_cert.pem nagios_server.key nagios_server.pem ../server/ssl
