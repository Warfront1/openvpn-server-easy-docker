# openvpn-server-easy-docker
### _OpenVPN Server in a Docker container that is easy to setup_

## Quick Start
Run the docker container:
```sh
docker run --name openvpn-server-easy -p 1194:1194/udp --device=/dev/net/tun --cap-add=NET_ADMIN warfront1osed/openvpn-server-easy:latest
```
Obtain the client's required connection files:
```sh
docker cp openvpn-server-easy:/client_credentials/. ./
```
Connect to the VPN using the client's required connection files on your preferred OpenVpn client.