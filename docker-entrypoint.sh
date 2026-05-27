#!/bin/bash
set -e

PHP_INI=/etc/php/7.4/apache2/php.ini

sed -i 's/display_startup_errors = Off/display_startup_errors = On/' $PHP_INI
sed -i 's/display_errors = Off/display_errors = On/' $PHP_INI
sed -i 's/allow_url_include = Off/allow_url_include = On/' $PHP_INI
sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/' $PHP_INI

PMA_CONFIG=/etc/phpmyadmin/config.inc.php
if [ -f "$PMA_CONFIG" ]; then
    sed -i "s/\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = false/\$cfg['Servers'][\$i]['AllowNoPassword'] = true/" $PMA_CONFIG
fi

echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Stop built-in MySQL since we use external MySQL container
service mysql stop 2>/dev/null || true

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
