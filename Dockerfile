FROM mirror.gcr.io/php:8.3-fpm-bookworm

RUN apt-get update \
 && apt-get install -y \
        apt-transport-https \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        zip \
        git \
        graphviz \
        curl \
 && docker-php-ext-install zip \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd \
 && docker-php-ext-install opcache \
 && docker-php-ext-configure pdo_mysql \
 && docker-php-ext-install pdo_mysql \
 && docker-php-ext-install pcntl \
 && docker-php-ext-install sockets \
 && docker-php-ext-enable sockets


COPY ./php-extensions/pecl/amqp /tmp/pecl/amqp

RUN apt-get update \
 && apt-get install -y librabbitmq-dev \
    automake \
    autoconf \
 && cd /tmp/pecl/amqp \
 && tar -zxf ./amqp-2.1.2.tgz \
 && cd /tmp/pecl/amqp/amqp-2.1.2 \
 && phpize \
 && ./configure \
 && make \
 && make install \
 && mkdir -p /usr/local/etc/mods-available \
 && echo "extension=amqp.so" > /usr/local/etc/mods-available/amqp.ini \
 && ln -s /usr/local/etc/mods-available/amqp.ini /usr/local/etc/php/conf.d/amqp.ini \
 && rm -rfv /tmp/pecl/amqp/*

RUN apt-get update \
 && apt-get install -y nginx \
 && rm -rf /etc/nginx/sites-available/* \
 && rm -rf /etc/nginx/sites-enabled/*

RUN apt-get update \
 && apt-get install -y supervisor

COPY ./supervisord/supervisord.conf /etc/supervisor/supervisord.conf
