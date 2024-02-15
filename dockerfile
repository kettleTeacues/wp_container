FROM ubuntu:22.04

# 必要なパッケージをインストール
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php php-fpm php-mysql mysql-server mysql-client

# タイムゾーンを設定
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# WordPressをダウンロードして展開
RUN apt-get install -y wget && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xvzf latest.tar.gz && \
    rm latest.tar.gz && \
    mv wordpress /var/www/ && \
    mv /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

# configファイルをコピー
COPY nginx/nginx.conf /etc/nginx/sites-available/default
COPY php-fpm/php.ini /etc/php/8.1/fpm/php.ini
COPY wordpress/info.php /var/www/wordpress/info.php
COPY wordpress/wp-config.php /var/www/wordpress/wp-config.php

RUN service mysql start && \
    mysql -e "CREATE DATABASE wordpress CHARACTER SET UTF8 COLLATE UTF8_BIN;" && \
    mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_user';" && \
    mysql -e "GRANT ALL ON wordpress.* to 'wp_user'@'localhost';"

# apache2を削除
RUN apt remove apache2 -y && \
    apt purge apache2 -y && \
    rm -rf /etc/apache2

# パーミッションを設定
RUN chown -R www-data:www-data /var/www/wordpress && \
    chmod -R 755 /var/www/wordpress

# nginxとphp-fpmのサービスを起動
CMD service nginx start && service mysql start && service php8.1-fpm start && tail -f /dev/null