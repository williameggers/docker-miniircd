#!/bin/sh

set -o errexit

: ${MINIIRCD_SSL_ENABLED:=1}

if [[ ${MINIIRCD_SSL_ENABLED} -eq 1 ]] ; then
    if [ ! -e "/var/jail/miniircd/ssl.pem" ] ; then
        echo "Generating self signed certificate."
        openssl req -x509 -newkey rsa:4086 \
            -subj "/C=/ST=/L=/O=/CN=" \
            -keyout "/var/jail/miniircd/ssl.pem" \
            -out "/var/jail/miniircd/ssl.crt" \
            -days 3650 -nodes -sha256
        cat /var/jail/miniircd/ssl.crt >> /var/jail/miniircd/ssl.pem && \
        rm -f /var/jail/miniircd/ssl.crt
        chown nobody:nobody /var/jail/miniircd/ssl.pem
    fi

    echo "Starting SSL enabled miniircd."
    exec /opt/miniircd/bin/miniircd \
        --debug \
        --verbose \
        --state-dir=/ \
        --channel-log-dir=/ \
        --motd=/motd.txt \
        --setuid=nobody \
        --ssl-pem-file=/ssl.pem \
        --chroot=/var/jail/miniircd
else
    echo "Starting miniircd."
    exec /opt/miniircd/bin/miniircd \
        --debug \
        --verbose \
        --state-dir=/ \
        --channel-log-dir=/ \
        --motd=/motd.txt \
        --setuid=nobody \
        --chroot=/var/jail/miniircd
fi