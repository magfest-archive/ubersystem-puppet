#!/bin/bash

# this script is run manually before you deploy with puppet
# it generates a CA, server certificate, and client certificate, for use with the RAMS Json-RPC API + Nginx

set -e

if [ "$#" -ne 6 ]
then
    echo "usage: $0 prefix country_code state location organization common_name"
    echo "example:"
    echo "$0 rams US MD Baltimore "Magfest INC" "onsite.uber.magfest.org""
    exit -1
fi

# put this before each cert name
prefix=$1

# stuff to build the DN of the certificate, doesn't matter too much except for common_name
# don't use spaces in these names
subj_country_code=$2
subj_state=$3
subj_location=$4
subj_organization=$5
subj_common_name=$6

subj="/C=$subj_country_code/ST=$subj_state/L=$subj_location/O=$subj_organization/CN"

subj_ca="$subj=$subj_common_name"
subj_server="$subj=$subj_common_name-server"
subj_client="$subj=$subj_common_name-client"

ssl_ca_key=${prefix}-ca.key
ssl_ca_crt=${prefix}-ca.crt
ssl_server_key=${prefix}-server.key
ssl_server_csr=${prefix}-server.csr
ssl_server_crt=${prefix}-server.crt
ssl_client_key=${prefix}-client.key
ssl_client_csr=${prefix}-client.csr
ssl_client_crt=${prefix}-client.crt

# create CA certificate
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "$subj_ca" -keyout $ssl_ca_key -out $ssl_ca_crt

# create server key and signing request
openssl genrsa -out $ssl_server_key 1024
openssl req -new -nodes -subj "$subj_server" -key $ssl_server_key -out $ssl_server_csr

# create server certificate signed by our CA
openssl x509 -req -days 365 -in $ssl_server_csr -CA $ssl_ca_crt -CAkey $ssl_ca_key -set_serial 01 -out $ssl_server_crt

# create client key and signing request
openssl genrsa -out $ssl_client_key 1024
openssl req -new -nodes -subj "$subj_client" -key $ssl_client_key -out $ssl_client_csr

# create client cert signed by our CA
openssl x509 -req -days 365 -in $ssl_client_csr -CA $ssl_ca_crt -CAkey $ssl_ca_key -set_serial 01 -out $ssl_client_crt

# kill the CSRs
/bin/rm $ssl_client_csr $ssl_server_csr
