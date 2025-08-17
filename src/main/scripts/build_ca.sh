#!/bin/bash
TEMP=$(getopt -n "$0" -a -l "servername:,sanip:,cakeypassword:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --servername) SERVER_NAME="$2"; shift;;
                    --sanip) SAN_IP="$2"; shift;;
                    --cakeypassword) CA_KEY_PASSWORD="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

# Require all arguments
if [ -z "${SERVER_NAME:-}" ] || [ -z "${SAN_IP:-}" ] || [ -z "${CA_KEY_PASSWORD:-}" ]; then
  echo "Usage: $0 --servername <FQDN-or-name> --sanip <IP> --cakeypassword <passphrase>" >&2
  exit 2
fi

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
./easyrsa gen-req $SERVER_NAME nopass
./easyrsa gen-dh
openvpn --genkey --secret /etc/openvpn/ta.key

/usr/bin/expect <<EOD
cd /etc/openvpn/easy-rsa
set timeout 20
spawn ./easyrsa --subject-alt-name=DNS:${SERVER_NAME},IP:${SAN_IP} sign-req server ${SERVER_NAME}
expect "Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key:"
send -- "$CA_KEY_PASSWORD"
send -- "\r"
expect eof
EOD

cd /etc/openvpn/easy-rsa/pki
cp ./dh.pem ./ca.crt ./issued/${SERVER_NAME}.crt ./private/${SERVER_NAME}.key /etc/openvpn/