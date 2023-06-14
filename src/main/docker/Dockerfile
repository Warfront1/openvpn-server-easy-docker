FROM ubuntu:22.04

RUN apt update && apt install -y \
    openvpn=2.5.5-1ubuntu3.1 easy-rsa=3.0.8-1ubuntu1 iptables=1.8.7-1ubuntu5.1 expect=5.45.4-2build1
RUN make-cadir /etc/openvpn/easy-rsa
COPY ./src/main/scripts /scripts
RUN cd /scripts && chmod +x *.sh
COPY ./src/main/resources /resources

CMD /scripts/setup.sh && openvpn --config /resources/myserver.conf