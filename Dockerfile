FROM php:8.4-fpm-alpine

# Instalar dependências de sistema e Nginx
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    zip \
    unzip \
    git \
    oniguruma-dev \
    libzip-dev

# Instalar extensões do PHP necessárias para o Laravel e MySQL/Postgres
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip opcache

# Copiar Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-interaction --prefer-dist --no-progress --no-dev --optimize-autoloader

# Configuração simples do Nginx apontando para a pasta /public do Laravel
RUN echo 'server { \
    listen 80; \
    index index.php index.html; \
    root /var/www/html/public; \
    location / { \
        try_files $uri $uri/ /index.php?$query_string; \
    } \
    location ~ \.php$ { \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_index index.php; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
        include fastcgi_params; \
    } \
}' > /etc/nginx/http.d/default.conf

# Ajustar permissões da pasta storage e cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

# Inicia o PHP-FPM em segundo plano e o Nginx na porta 80
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]