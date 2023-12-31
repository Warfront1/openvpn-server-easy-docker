#!/bin/bash
TEMP=$(getopt -n "$0" -a -l "cakeypassword:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --cakeypassword) CA_KEY_PASSWORD="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done
export EASYRSA_BATCH=1

cd /etc/openvpn/easy-rsa
./easyrsa init-pki

/usr/bin/expect <<EOD
cd /etc/openvpn/easy-rsa
set timeout 20
spawn ./easyrsa build-ca
expect "Enter New CA Key Passphrase:"

send -- "$CA_KEY_PASSWORD"
send -- "\r"

sleep 2
expect "Enter New CA Key Passphrase:"
send -- "$CA_KEY_PASSWORD"
send -- "\r"
expect eof
EOD

cd /etc/openvpn/easy-rsa
./easyrsa gen-req myservername nopass
./easyrsa gen-dh
openvpn --genkey --secret /etc/openvpn/ta.key

/usr/bin/expect <<EOD
cd /etc/openvpn/easy-rsa
set timeout 20
spawn ./easyrsa sign-req server myservername
expect "Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:"
send -- "$CA_KEY_PASSWORD"
send -- "\r"
expect eof
EOD

cd /etc/openvpn/easy-rsa/pki
cp ./dh.pem ./ca.crt ./issued/myservername.crt ./private/myservername.key /etc/openvpn/