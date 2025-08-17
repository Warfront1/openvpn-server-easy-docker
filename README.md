# openvpn-server-easy-docker
### _OpenVPN Server in a Docker container that is easy to setup_

This OpenVPN Sever setup automation closely follows best practices such as those found in official [Ubuntu OpenVPN documentation](https://documentation.ubuntu.com/server/how-to/security/install-openvpn/).

## Quick Start

1.  **Run the Docker container:**
    ```sh
    docker run --name openvpn-server-easy -p 1194:1194/udp --device=/dev/net/tun --cap-add=NET_ADMIN warfront1osed/openvpn-server-easy:latest
    ```

2.  **Obtain client credentials:**
    ```sh
    docker cp openvpn-server-easy:/client_credentials/. ./
    ```
    This command copies the client configuration files from the container to your current directory.

3.  **Connect to the VPN:**
    The easiest way to connect is by importing the `client.ovpn` file into an OpenVPN client.

    We recommend [OpenVPN Connect](https://openvpn.net/client/), the official client, which is available on:
    *   🪟 Windows
    *   🍏 macOS
    *   🐧 Linux
    *   📱 iOS
    *   🤖 Android
    *   🌐 ChromeOS

    If your client does not support `.ovpn` profiles, or you prefer to configure it manually, use the following files:
    *   `ca.crt`
    *   `client.crt`
    *   `client.key`
    *   `ta.key`