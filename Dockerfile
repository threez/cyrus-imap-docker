FROM alpine:latest as builder

RUN apk --no-cache add autoconf \
                       automake \
                       make \
                       bison \
                       libsasl \
                       flex \
                       gcc \
                       g++ \
                       gperf \
                       jansson-dev \
                       libbsd-dev \
                       libtool \
                       icu-dev \
                       libuuid \
                       openssl-dev \
                       pkgconfig \
                       sqlite-dev \
                       postgresql-dev \
                       libical-dev \
                       libxml2-dev \
                       brotli-dev \
                       zlib-dev \
                       openldap-dev \
                       net-snmp-dev \
                       clamav-dev \
                       pcre-dev \
                       nghttp2-dev \
                       perl-dev

RUN wget https://www.cyrusimap.org/releases/cyrus-imapd-3.0.10.tar.gz && \
    tar -zxf cyrus-imapd-3.0.10.tar.gz
RUN cd cyrus-imapd-3.0.10/ && \
    autoreconf -i && \
    ./configure --enable-autocreate --enable-idled --enable-nntp \
                --enable-murder --enable-http --enable-calalarmd \
                --disable-dependency-tracking --with-ldap --with-pgsql && \
    make && \
    make install
RUN cd cyrus-imapd-3.0.10/ && \
    mkdir -p   /usr/local/cyrus/tools && \
    cp -r tools/* /usr/local/cyrus/tools/ && \
    chmod 755  /usr/local/cyrus/tools/*

### FINAL IMAGE

FROM alpine:latest
LABEL org.label-schema.name = "cyrus-imap"
LABEL org.label-schema.description="Docker container for cyrus-imap 3.x based on alpine"
LABEL org.label-schema.url="https://github.com/threez/cyrus-imap-docker"
LABEL org.label-schema.vcs-url = "https://github.com/threez/cyrus-imap-docker"
LABEL org.label-schema.version = "3.0.10"
LABEL org.label-schema.schema-version = "1.0"
LABEL org.label-schema.docker.cmd="docker run --rm -ti -p 80:80 -p 143:143 -p 110:110 -p 2000:2000 -p 24:24 threez/cyrus-imap:latest"

COPY --from=builder /usr/local /usr/local

RUN apk --no-cache add jansson \
                       brotli \
                       zlib \
                       pcre \
                       libsasl \
                       openldap \
                       net-snmp \
                       nghttp2-libs \
                       clamav-libs \
                       postgresql-libs \
                       libical \
                       libxml2 \
                       sqlite-libs \
                       openssl \
                       libuuid \
                       libbsd \
                       icu-libs \
                       perl \
                       ca-certificates \
                       cyrus-sasl \
                       cyrus-sasl-login \
                       cyrus-sasl-plain \
                       cyrus-sasl-digestmd5 \
                       cyrus-sasl-crammd5
RUN mkdir -p /var/lib/cyrus \
             /var/lib/cyrus/db \
             /var/lib/cyrus/socket \
             /var/lib/cyrus/zoneinfo \
             /run/cyrus/proc \
             /run/cyrus/socket \
             /run/cyrus/saslauthd \
             /var/spool/cyrus \
             /var/spool/sieve
ADD imapd.conf /etc/imapd.conf
ADD cyrus.conf /etc/cyrus.conf
RUN /usr/local/cyrus/tools/mkimap
RUN chown -R cyrus:mail /var/lib/cyrus \
                        /run/cyrus \
                        /var/spool/cyrus \
                        /var/spool/sieve && \
    chmod 750 /var/lib/cyrus \
              /run/cyrus \
              /var/spool/cyrus \
              /var/spool/sieve
RUN mkdir -p /run/saslauthd && \
    chown -R cyrus:mail /run/saslauthd /etc/sasl2 && \
    chmod 750 /run/saslauthd
RUN sh -c "echo secret | saslpasswd2 -p -c cyrus" && \
    chown cyrus:mail /etc/sasl2/sasldb2

EXPOSE 110
EXPOSE 143
EXPOSE 80
EXPOSE 2000
EXPOSE 24

ENV CYRUS_VERBOSE 100

# we chage the dev to be writeable by cyrus so that we
# can start syslog inside the master process
CMD ["/bin/sh", "-c", "chown -R cyrus:mail /dev && exec /usr/local/libexec/master -D"]
