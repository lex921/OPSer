FROM php:7.4-fpm
WORKDIR /app
COPY index.php /app
RUN /usr/local/bin/docker-php-ext-install pdo_mysql
RUN /usr/local/bin/docker-php-ext-install mysqli
