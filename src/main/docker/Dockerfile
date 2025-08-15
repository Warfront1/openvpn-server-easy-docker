FROM ubuntu:noble-20250716

RUN apt update && apt install -y \
    openvpn=2.6.14-0ubuntu0.24.04.1 easy-rsa=3.1.7-2 iptables=1.8.10-3ubuntu2 curl=8.5.0-2ubuntu10.6 expect=5.45.4-3
RUN make-cadir /etc/openvpn/easy-rsa
COPY ./src/main/scripts /scripts
RUN cd /scripts && chmod +x *.sh
COPY ./src/main/resources /resources

CMD /scripts/setup.sh && openvpn --config /resources/myserver.conf