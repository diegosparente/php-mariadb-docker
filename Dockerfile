FROM php:7.4-cli
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        git curl zip \
        libonig-dev \
        libxml2-dev \
        libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip mysqli pdo_mysql mbstring exif pcntl bcmath opcache soap

RUN pecl install xdebug-2.9.8 \
    && docker-php-ext-enable xdebug

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN usermod -u 1000 www-data

WORKDIR /var/www/html

COPY src/ /var/www/html

EXPOSE 9000

CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]
