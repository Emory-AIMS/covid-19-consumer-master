FROM ubuntu:18.04 AS open-resty-base

# install some prerequisites needed by adding GPG public keys (could be removed later)
RUN apt-get update && \
    apt-get -y install --no-install-recommends wget gnupg ca-certificates && \
        # import our GPG key: \
        wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -  && \
        apt-get -y install --no-install-recommends software-properties-common && \
        add-apt-repository -y "deb http://openresty.org/package/ubuntu bionic main" && \
        apt-get update && \
        apt-get -y install git cron python python3-pip logrotate vim procps psmisc openresty openresty-openssl libssl1.0-dev luarocks && \
        pip3 install awscli && \
        apt-get update && \
        luarocks install sha1 && \
        luarocks install lua-resty-mysql && \
        luarocks install lua-resty-redis && \
        luarocks install lua-resty-string && \
        luarocks install lua-resty-jwt 0.2.0 && \
        luarocks install lua-resty-http && \
        apt-get clean

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

RUN mkdir -p /var/run/openresty

EXPOSE 80
STOPSIGNAL SIGTERM