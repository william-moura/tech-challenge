# Base PHP FPM
FROM php:8.4-fpm-alpine

# Instalar dependências de sistema e extensões PHP essenciais
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    oniguruma-dev \
    icu-dev \
    libzip-dev

RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Copiar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Adicione esta linha no seu Dockerfile:
COPY openapi.yaml /var/www/html/public/openapi.yml

# Copiar arquivos do projeto
COPY . .

# Instalar dependências do Composer sem pacotes de dev
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Ajustar permissões essenciais do Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Garantir que o diretório de logs do supervisor existe
RUN mkdir -p /var/log/supervisor

# Copiar configurações
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expor a porta HTTP padrão (80)
EXPOSE 80

# Iniciar Supervisor (que gerencia o Nginx e o PHP-FPM juntos)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]