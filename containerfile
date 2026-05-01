#====== Deliverer ======
FROM docker.io/alpine:3.22 AS deliverer

RUN set -eux; \
  apk add --no-cache git; \
  git clone --depth 1 --branch v601 --single-branch https://github.com/Atheos/Atheos /tmp/atheos; \
  rm -rf /tmp/atheos/.git

#====== Image Starts From Here ======
FROM php:7.4-apache
#====== apt & php_mods Installation ======
RUN set -eux; \
  apt-get update; \
  apt-get upgrade -y; \
  apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
    libonig-dev; \
  rm -rf /var/lib/apt/lists/*; \
  docker-php-ext-install mbstring zip opcache; \
  a2enmod rewrite


#====== Generating vhost Configuration File ======
RUN cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>
</VirtualHost>
EOF


#====== Preparation for Atheos ======
COPY --from=deliverer /tmp/atheos /var/www/html/
COPY --chmod=0755 start.sh /usr/local/bin/start.sh

RUN set -eux; \
  mkdir -p /var/www/html/data/users; \
  echo 'ServerName localhost' >>/etc/apache2/apache2.conf; \
  chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
