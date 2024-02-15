FROM ubuntu:22.04

# 必要なパッケージをインストール
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nginx php-fpm mysql-server mysql-client php-mysql

# タイムゾーンを設定
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# WordPressをダウンロードして展開
RUN apt-get install -y wget && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xvzf latest.tar.gz && \
    rm latest.tar.gz && \
    mv wordpress /var/www/html/ && \
    mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

# パーミッションを設定
RUN chown -R www-data:www-data /var/www/html/wordpress && \
    chmod -R 755 /var/www/html/wordpress

# configファイルをコピー
COPY nginx/nginx.conf /etc/nginx/sites-available/default
COPY php-fpm/php.ini /etc/php/8.1/fpm/php.ini
COPY wordpress/info.php /var/www/wordpress/info.php
COPY wordpress/wp-config.php /var/www/html/wordpress/wp-config.php

# apache2を削除
RUN apt remove apache2 -y && \
    apt purge apache2 -y && \
    rm -rf /etc/apache2

# ポート80を公開
EXPOSE 80

# nginxとphp-fpmのサービスを起動
CMD service nginx start && service php8.1-fpm start && tail -f /dev/null
