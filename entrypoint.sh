#!/bin/sh

set -o errexit

: ${MINIIRCD_SSL_ENABLED:=1}
: ${MINIIRCD_CHANNEL_LOG_ENABLED:=1}
: ${MINIIRCD_BOUNCER_BUFFER_SIZE:=512}
: ${MINIIRCD_MAX_CLIENTS:=128}
: ${MINIIRCD_NEW_REGISTRATIONS:=128}
: ${MINIIRCD_MAX_CHANNELS:=8}
: ${MINIIRCD_MAX_FLOOD_SCORE:=20}
: ${MINIIRCD_CLOAK_HOST:=}

MINIIRCD_VERSION=$(/opt/miniircd/bin/miniircd --version)
MINIIRCD_OPT_ARGS=""

if [[ ${MINIIRCD_CHANNEL_LOG_ENABLED} -eq 1 ]] ; then
    MINIIRCD_OPT_ARGS="--channel-log-dir=/"
fi

if [ ! -z "${MINIIRCD_CLOAK_HOST}" ] ; then
    echo "Using cloak hostname $MINIIRCD_CLOAK_HOST"
    MINIIRCD_OPT_ARGS="$MINIIRCD_OPT_ARGS --cloak=$MINIIRCD_CLOAK_HOST "
fi

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

    echo "Starting SSL enabled miniircd (v$MINIIRCD_VERSION)."
    exec /opt/miniircd/bin/miniircd \
        --debug \
        --verbose \
        --ports=6697 \
        --state-dir=/ \
        --bouncer-size=$MINIIRCD_BOUNCER_BUFFER_SIZE \
        --max-clients=$MINIIRCD_MAX_CLIENTS \
        --new-registrations=$MINIIRCD_NEW_REGISTRATIONS \
        --max-flood-score=$MINIIRCD_MAX_FLOOD_SCORE \
        --max-channels=$MINIIRCD_MAX_CHANNELS \
        --motd=/motd.txt \
        --setuid=nobody \
        --ssl-pem-file=/ssl.pem \
        $MINIIRCD_OPT_ARGS --chroot=/var/jail/miniircd
else
    echo "Starting miniircd (v$MINIIRCD_VERSION)."
    exec /opt/miniircd/bin/miniircd \
        --debug \
        --verbose \
        --ports=6667 \
        --state-dir=/ \
        --bouncer-size=$MINIIRCD_BOUNCER_BUFFER_SIZE \
        --max-clients=$MINIIRCD_MAX_CLIENTS \
        --new-registrations=$MINIIRCD_NEW_REGISTRATIONS \
        --max-flood-score=$MINIIRCD_MAX_FLOOD_SCORE \
        --max-channels=$MINIIRCD_MAX_CHANNELS \
        --motd=/motd.txt \
        --setuid=nobody \
        $MINIIRCD_OPT_ARGS --chroot=/var/jail/miniircd
fi