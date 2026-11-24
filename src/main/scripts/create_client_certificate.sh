#!/bin/bash
TEMP=$(getopt -n "$0" -a -l "clientname:,clientpassword:,cakeypassword:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --clientname) CLIENT_NAME="$2"; shift;;
                    --clientpassword) CLIENT_PASSWORD="$2"; shift;;
                    --cakeypassword) CA_KEY_PASSWORD="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done
export EASYRSA_BATCH=1
cd /etc/openvpn/easy-rsa
./easyrsa gen-req $CLIENT_NAME $CLIENT_PASSWORD

/usr/bin/expect <<EOD
cd /etc/openvpn/easy-rsa
set timeout 20
spawn ./easyrsa sign-req client $CLIENT_NAME
expect "Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:"
send -- "$CA_KEY_PASSWORD"
send -- "\r"
expect eof
EOD

mkdir /client_credentials
cd /etc/openvpn/easy-rsa/pki
cp /etc/openvpn/ta.key ./private/$CLIENT_NAME.key ./issued/$CLIENT_NAME.crt ./ca.crt /client_credentials/
