FROM ubuntu:resolute-20260707

RUN apt update && apt install -y \
    openvpn=2.7.0-1ubuntu1.4 easy-rsa=3.2.5-1 iptables=1.8.11-2ubuntu3 curl=8.18.0-1ubuntu2.8 expect=5.45.4-4build1
RUN make-cadir /etc/openvpn/easy-rsa
COPY ./src/main/scripts /scripts
RUN cd /scripts && chmod +x *.sh
COPY ./src/main/resources /resources

CMD /scripts/setup.sh && openvpn --config /resources/myserver.conf