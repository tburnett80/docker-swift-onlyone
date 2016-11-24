FROM ubuntu:16.04
MAINTAINER tim <tim@timburnett.io>

WORKDIR /files

COPY /files /files

RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository cloud-archive:newton && apt-get update && \
    apt-get install -y supervisor swift python-swiftclient rsync \
                       swift-proxy swift-object memcached python-keystoneclient \
                       python-swiftclient swift-plugin-s3 python-netifaces \
                       python-xattr python-memcache \
                       swift-account swift-container swift-object pwgen && \
    mkdir -p /var/log/supervisor && apt-get autoremove -y && \
    mv dispersion.conf /etc/swift/dispersion.conf && \
    mv rsyncd.conf /etc/rsyncd.conf && \
    mv swift.conf /etc/swift/swift.conf && \
    mv proxy-server.conf /etc/swift/proxy-server.conf && \
    mv account-server.conf /etc/swift/account-server.conf && \
    mv object-server.conf /etc/swift/object-server.conf && \
    mv container-server.conf /etc/swift/container-server.conf && \
    mv supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
    chmod 755 startmain.sh && chmod 775 /var/log && touch /var/log/syslog

EXPOSE 8080

CMD /files/startmain.sh
