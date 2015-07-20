FROM debian:wheezy

MAINTAINER Vincent Chalamon <vincentchalamon@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      curl \
      wget \
      nginx \
      sqlite3 \
      supervisor

RUN echo 'deb http://packages.dotdeb.org wheezy all' >> /etc/apt/sources.list \
    && echo 'deb-src http://packages.dotdeb.org wheezy all' >> /etc/apt/sources.list \
    && echo 'deb http://packages.dotdeb.org wheezy-php55 all' >> /etc/apt/sources.list \
    && echo 'deb-src http://packages.dotdeb.org wheezy-php55 all' >> /etc/apt/sources.list \
    && wget -O - http://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update && apt-get install -y --no-install-recommends \
      php5 \
      php5-apcu \
      php5-cli \
      php5-curl \
      php5-fpm \
      php5-intl \
      php5-json \
      php5-mysql \
      php5-sqlite \
      php5-pgsql \
      php5-memcache \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf \
    && sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf \
    && sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
    && echo "apc.enabled=1" >> /etc/php5/cli/20-apcu.ini \
    && echo "apc.stat=1" >> /etc/php5/cli/20-apcu.ini \
    && echo "apc.enabled=1" >> /etc/php5/fpm/20-apcu.ini \
    && echo "apc.stat=1" >> /etc/php5/fpm/20-apcu.ini \
    && echo "date.timezone=UTC" >> /etc/php5/cli/php.ini \
    && echo "date.timezone=UTC" >> /etc/php5/fpm/php.ini \
    && echo "opcache.enable=1" >> /etc/php5/fpm/conf.d/05-opcache.ini \
    && echo "opcache.enable_cli=1" >> /etc/php5/cli/conf.d/05-opcache.ini

ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

ADD vhost.conf /etc/nginx/sites-available/default

RUN usermod -u 1000 www-data

VOLUME /var/www
WORKDIR /var/www

EXPOSE 80

CMD ["/usr/bin/supervisord"]
