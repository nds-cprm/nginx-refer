
FROM debian:buster-slim

LABEL maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>"

ENV NGINX_VERSION   1.18.0
ENV NJS_VERSION     0.4.4
ENV PKG_RELEASE     1~buster

RUN set -xe ; \
# create nginx user/group first, to be consistent throughout docker variants
    addgroup --system --gid 101 nginx ; \
    adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx ; \
    apt-get update ; \
    apt-get install --no-install-recommends --no-install-suggests -y curl gnupg ca-certificates ; \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - ; \
    echo "deb http://nginx.org/packages/debian buster slim nginx" > /etc/apt/sources.list.d/nginx.list ; \
    apt update ; \
    apt install nginx ; \
    nginxPackages=" \
        nginx=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-${PKG_RELEASE} \
        " ; \ 
# forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log ; \
    ln -sf /dev/stderr /var/log/nginx/error.log ; \
    echo " setup done!"

# create a docker-entrypoint.d directory
RUN set -ex ; \
    mkdir /docker-entrypoint.d

COPY docker-entrypoint.sh /

#COPY 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
#COPY 20-envsubst-on-templates.sh /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]

# agsb@ let compose docker select
# EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
