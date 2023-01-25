FROM php:8.1-apache

# Install packages
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1
RUN apt -y update
RUN apt -y install --no-install-recommends \
    locales \
    apt-utils \
    zbar-tools \
    bash \
    wget \
    git \
    dbus \
    libicu-dev \
    ghostscript \
    gnupg2 \
    pdftk \
    zlib1g-dev \
    libzip-dev \
    unzip

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install nodejs
RUN export NODE_OPTIONS=--openssl-legacy-provider

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt -y update && apt -y install --no-install-recommends yarn

# Generate locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Install php extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl
RUN docker-php-ext-install zip

# Install composer
RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
    mv composer.phar /usr/local/bin/composer

# Install symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli

# Allow dbus
RUN dbus-uuidgen > /var/lib/dbus/machine-id
RUN mkdir -p /var/run/dbus
RUN dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Allow htaccess rewrite
RUN a2enmod rewrite
RUN service apache2 restart

EXPOSE 80
EXPOSE 8000

RUN mkdir /var/www/project

WORKDIR /var/www/project

RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

CMD apache2-foreground
