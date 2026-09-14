FROM php:8.4-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    curl \
    nginx

RUN docker-php-ext-install pdo_mysql mbstring bcmath gd

# Copiar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_MEMORY_LIMIT=-1
WORKDIR /var/www/html

# 1. Copia dependências e instala sem rodar scripts do Artisan
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-progress --no-dev --optimize-autoloader --no-scripts

# 2. Copia o código completo
COPY . .

# 3. Gera o autoloader final do Composer
RUN composer dump-autoload --optimize

# Permissões das pastas do Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 80

CMD ["sh", "-c", "php artisan config:cache && php artisan route:cache && php-fpm"]