FROM php:7.2-fpm-stretch
LABEL maintainer="Adrian Pasten <fredpalas@apperturedev.es>"

#install laravel requirements and aditional extensions
RUN requirements="apt-utils libmcrypt-dev g++ libicu-dev libmcrypt4 libmcrypt-dev libzip4 libzip-dev zlib1g-dev git libpng-dev libbz2-dev libpq-dev libxml2-dev curl libcurl4-openssl-dev libpng16-16 libpq5" \
    && apt-get update && apt-get install -y $requirements \
    && ldconfig \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql \
    && docker-php-ext-install mysqli \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-install intl \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip \
    && docker-php-ext-install gd \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install bcmath \
    && pecl install apcu \ 
    && docker-php-ext-enable apcu \    
    && apt-get purge --auto-remove -y libmcrypt-dev g++ libicu-dev zlib1g-dev libpq-dev libbz2-dev libxml2-dev libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

#install composer globally
RUN curl -sSL https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#replace default php-fpm config
RUN rm -v /usr/local/etc/php-fpm.conf

COPY config/php-fpm.conf /usr/local/etc/

#add custom php.ini
COPY config/php.ini /usr/local/etc/php/

RUN usermod -u 1000 www-data \
    && groupmod -g 1000 www-data

# Setup Volume
VOLUME ["/usr/share/nginx/html"]

#Set Workdir
WORKDIR /usr/share/nginx/html

#Add entrypoint
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
