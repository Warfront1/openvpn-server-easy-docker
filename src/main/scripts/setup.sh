#!/usr/bin/env bash
LOCK_FILE="/.setup_done"

# This command needs to run every time the container starts
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

# Exit if setup has already been completed
if [ -f "$LOCK_FILE" ]; then
    echo "Setup already complete. Skipping."
    exit 0
fi

echo "Performing first-time setup..."
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

# Create the lock file to indicate setup is complete
touch "$LOCK_FILE"
echo "First-time setup complete."
