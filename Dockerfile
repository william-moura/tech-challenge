FROM php:8.4-fpm-alpine

# Instalar dependências de sistema e extensões PHP necessárias para o Laravel
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    pdo_pgsql \
    pdo_mysql \
    zip \
    unzip \
    git

RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql gd bcmath

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiar arquivos do projeto
COPY . .

# Instalar dependências sem dev
RUN composer install --no-dev --optimize-autoloader

# Ajustar permissões de escrita para o Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["php-fpm"]