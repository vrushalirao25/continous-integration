FROM php:8.2-cli

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libzip-dev \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql zip intl

COPY --from=composer:latest /usr/bin/composer  /usr/bin/composer

COPY . .

RUN rm -rf vendor && composer install --no-dev --optimize-autoloader

RUN if [ ! -f .env ]; then cp .env.example .env; fi

RUN php artisan key:generate

RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

RUN chmod -R 755 storage bootstrap/cache
RUN chmod -R 775 storage
RUN chmod -R 775 bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]