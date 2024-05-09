# SPDX-License-Identifier: GPL-2.0-only
ARG BASE_IMAGE=dunglas/frankenphp
ARG FRANKENPHP_VERSION=1.1.1
ARG PHP_VERSION=8.2
ARG OS_FLAVOR=alpine
ARG REPOSITORY=docker.io

FROM ${REPOSITORY}/${BASE_IMAGE}:${FRANKENPHP_VERSION}-php${PHP_VERSION}-${OS_FLAVOR}
ARG INVOICE_NINJA_VERSION
LABEL org.opencontainers.image.base.name="dunglas/frankenphp"
LABEL org.opencontainers.image.description="Light-ish Invoice Ninja image using FrankenPHP"
LABEL org.opencontainers.image.licenses="GPL-2.0-only"
LABEL org.opencontainers.image.title="Invoice Ninja"
LABEL org.opencontainers.image.authors="Florian Lavidalie"
LABEL org.opencontainers.image.vendor="Florian Lavidalie"
LABEL org.opencontainers.image.version="${INVOICE_NINJA_VERSION}"
LABEL org.opencontainers.image.url="https://gitlab.0x2a.ninja/flowtech/oss/invoice-ninja"

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV IS_DOCKER=1
ENV APP_ENV=production
ENV PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d
ENV SNAPPDF_CHROMIUM_PATH=/usr/bin/chromium
ENV SNAPPDF_EXECUTABLE_PATH=/usr/bin/chromium
ENV XDG_CONFIG_HOME=/tmp

RUN set -eux; \
    addgroup -g ${GROUP_ID} invoice \
    && adduser -DH -u ${USER_ID} -G invoice invoice -s /bin/sh -h /app \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && chown -R ${USER_ID}:${GROUP_ID} /data/caddy \
    && chown -R ${USER_ID}:${GROUP_ID} /config/caddy \
    && chown -R ${USER_ID}:${GROUP_ID} /app \
    && rm "$PHP_INI_DIR"/php.ini* \
    ;

COPY ./config/php.ini /usr/local/etc/php/php.ini

RUN set -eux; \
    apk upgrade --no-cache --update --no-interactive \
    && apk add --no-cache --update \
      chromium \
      mariadb-client \
      tini \
    && install-php-extensions \
      bcmath \
      gd \
      gmp \
      pdo_mysql \
      zip \
    && curl -so /usr/local/bin/composer https://getcomposer.org/download/latest-stable/composer.phar \
    && chmod 555 /usr/local/bin/composer \
    && ls -lah /usr/local/bin/composer \
    && (find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true) \
    ;

COPY ./config/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY ./config/Caddyfile /etc/caddy/Caddyfile
COPY --chown=invoice:invoice ./application /app

WORKDIR /app
USER invoice
RUN set -eux; \
    touch .env \
    && composer install --no-dev --no-progress --optimize-autoloader --no-interaction \
    ;

EXPOSE 443/tcp 443/udp
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-php-entrypoint"]
CMD ["--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
