FROM python:3-alpine

USER root

ADD https://raw.githubusercontent.com/jrosdahl/miniircd/master/miniircd /opt/miniircd/bin/miniircd

COPY motd.txt /var/jail/miniircd/motd.txt

RUN chmod 755 /opt/miniircd/bin/miniircd && \
    chown -R nobody:nobody /var/jail/miniircd

# Install OpenSSL
RUN apk update && \
    apk add --no-cache openssl && \
    rm -rf "/var/cache/apk/*"

COPY entrypoint.sh /

EXPOSE 6667 6697
ENTRYPOINT ["/entrypoint.sh"]