FROM python:3-alpine

USER root

#ADD https://raw.githubusercontent.com/bashrc2/miniircd/main/miniircd /opt/miniircd/bin/miniircd
COPY miniircd /opt/miniircd/bin/miniircd
COPY motd.txt /var/jail/miniircd/motd.txt

RUN chmod 755 /opt/miniircd/bin/miniircd && \
	mkdir -p /var/jail/miniircd/dev && \
	chmod 755 /var/jail/miniircd && \
	mknod /var/jail/miniircd/dev/null c 1 3 && \
	mknod /var/jail/miniircd/dev/urandom c 1 9 && \
	chmod 666 /var/jail/miniircd/dev/* && \
    chown -R nobody:nobody /var/jail/miniircd 

# Install OpenSSL
RUN apk update && \
    apk add --no-cache openssl && \
    rm -rf "/var/cache/apk/*"

COPY entrypoint.sh /

EXPOSE 6667 6697
ENTRYPOINT ["/entrypoint.sh"]