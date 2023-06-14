CA_KEY_PASSWORD="${CA_KEY_PASSWORD:=test}"
CLIENT_NAME="${CLIENT_NAME:=client}"
CLIENT_PASSWORD="${CLIENT_PASSWORD:=nopass}"

/scripts/build_ca.sh --cakeypassword $CA_KEY_PASSWORD
/scripts/create_client_certificate.sh --clientname $CLIENT_NAME --clientpassword $CLIENT_PASSWORD --cakeypassword $CA_KEY_PASSWORD
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
