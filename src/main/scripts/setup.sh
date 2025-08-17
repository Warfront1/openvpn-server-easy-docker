#!/usr/bin/env bash
SERVER_NAME="${CA_SERVER_NAME:=myservername}"
CA_KEY_PASSWORD="${CA_KEY_PASSWORD:=test}"
CLIENT_NAME="${CLIENT_NAME:=client}"
CLIENT_PASSWORD="${CLIENT_PASSWORD:=nopass}"

source /scripts/get_public_ip.sh
PUBIP="$(get_public_ip)"

/scripts/build_ca.sh --servername $SERVER_NAME --sanip $PUBIP --cakeypassword $CA_KEY_PASSWORD
/scripts/create_client_certificate.sh --clientname $CLIENT_NAME --clientpassword $CLIENT_PASSWORD --cakeypassword $CA_KEY_PASSWORD

# Generate inline client profile (.ovpn) directly into /client_credentials/
/scripts/generate_client_ovpn.sh --server-host "$PUBIP" --clientname "$CLIENT_NAME" --verify-x509-name "$SERVER_NAME" --output "/client_credentials/${CLIENT_NAME}.ovpn"

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
