# openvpn-server-easy-docker
### _OpenVPN Server in a Docker container that is easy to setup_

This OpenVPN Sever setup automation closely follows best practices such as those found in official [Ubuntu OpenVPN documentation](https://documentation.ubuntu.com/server/how-to/security/install-openvpn/).

## Quick Start

1.  **Run the Docker container:**  
    ```sh
    docker run --name openvpn-server-easy --restart=unless-stopped -d -p 1194:1194/udp --device=/dev/net/tun --cap-add=NET_ADMIN warfront1osed/openvpn-server-easy:latest && docker logs -f openvpn-server-easy
    ```

2.  **Wait for OpenVPN to start:**  
    You will see `Initialization Sequence Completed` in the logs when OpenVPN is ready to use.

3.  **Obtain client credentials:**  
    > **Tip:** To run the next command, you can either open a new terminal or press `Ctrl+C` to exit the log stream.

    ```sh
    docker cp openvpn-server-easy:/client_credentials/. ./
    ```
    This command copies the client configuration files from the container to your current directory.

4.  **Connect to the VPN:**  
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