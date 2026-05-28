FROM ubuntu:22.04

LABEL maintainer="kawasakikidou"
LABEL description="Pikachu on PHP7.4 + Apache (ARM64/AMD64)"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Install Apache, PHP 7.4 from ondrej/ppa (supports both arm64/amd64)
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common gnupg ca-certificates && \
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
        php7.4-zip \
        php7.4-dev \
        php-pear \
        mysql-client \
        expect \
        tcl-dev \
        tcl-expect-dev \
        acl \
        sudo && \
    ln -s /usr/include/tcl8.6/tcl.h /usr/include/tcl.h && \
    ln -s /usr/include/tcl8.6/tclDecls.h /usr/include/tclDecls.h && \
    ln -s /usr/include/tcl8.6/expect_tcl.h /usr/include/expect_tcl.h && \
    ln -s /usr/include/tcl8.6/tclPlatDecls.h /usr/include/tclPlatDecls.h && \
    pecl channel-update pecl.php.net && \
    printf "\n" | pecl install expect && \
    echo "extension=expect.so" >> /etc/php/7.4/apache2/php.ini && \
    echo "extension=expect.so" >> /etc/php/7.4/cli/php.ini && \
    phpenmod expect

# Configure PHP for security testing
RUN sed -i 's/display_startup_errors = Off/display_startup_errors = On/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/allow_url_include = Off/allow_url_include = On/' /etc/php/7.4/apache2/php.ini && \
    sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/' /etc/php/7.4/apache2/php.ini

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy application
COPY . /app/

# Configure Apache document root
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /app|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|<Directory /var/www/html>|<Directory /app>|' /etc/apache2/sites-available/000-default.conf && \
    echo '<Directory /app>\n    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>' >> /etc/apache2/apache2.conf

# Configure Apache user to match app permissions
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data || true

# Clean up
RUN apt-get remove -y php7.4-dev php-pear tcl-dev tcl-expect-dev software-properties-common gnupg && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 80

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
