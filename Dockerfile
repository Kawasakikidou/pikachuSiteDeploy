FROM php:8.1-apache

LABEL description="Pikachu on PHP8.1 + Apache (ARM64/AMD64)"

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN docker-php-ext-install mysqli pdo pdo_mysql && \
    apt-get update && \
    apt-get install -y --no-install-recommends default-mysql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/display_startup_errors = Off/display_startup_errors = On/' \
           -e 's/display_errors = Off/display_errors = On/' \
           -e 's/allow_url_include = Off/allow_url_include = On/' \
           -e 's/allow_url_fopen = Off/allow_url_fopen = On/' \
        "$PHP_INI_DIR/php.ini" && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod rewrite

COPY . /app/

RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /app|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|<Directory /var/www/html>|<Directory /app>|' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
