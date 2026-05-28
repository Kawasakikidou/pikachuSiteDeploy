FROM ubuntu:22.04

LABEL description="Pikachu on PHP8.1 + Apache (ARM64/AMD64)"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 libapache2-mod-php \
        php php-cli php-mysql php-curl php-mbstring php-gd php-xml \
        mysql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/display_startup_errors = Off/display_startup_errors = On/' \
           -e 's/display_errors = Off/display_errors = On/' \
           -e 's/allow_url_include = Off/allow_url_include = On/' \
           -e 's/allow_url_fopen = Off/allow_url_fopen = On/' \
        /etc/php/8.1/apache2/php.ini && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY . /app/

RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /app|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|<Directory /var/www/html>|<Directory /app>|' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
