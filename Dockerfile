FROM ubuntu:22.04

LABEL description="Pikachu on PHP7.4 + Apache (ARM64/AMD64)"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common gnupg && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 \
        libapache2-mod-php7.4 \
        php7.4 \
        php7.4-cli \
        php7.4-mysql \
        php7.4-curl \
        php7.4-json \
        php7.4-xml \
        php7.4-mbstring \
        php7.4-gd \
        mysql-client && \
    apt-get remove -y software-properties-common gnupg && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/display_startup_errors = Off/display_startup_errors = On/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/allow_url_include = Off/allow_url_include = On/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/' /etc/php/7.4/apache2/php.ini && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY . /app/

RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /app|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|<Directory /var/www/html>|<Directory /app>|' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
