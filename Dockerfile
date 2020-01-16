

FROM debian:buster

RUN apt update && \
	apt upgrade && \
	apt -y install nginx mariadb-server php-mbstring php-fpm php-mysql && \
	apt -y install openssl


COPY srcs/wordpress /var/www/gconde/html/wordpress
COPY srcs/config_nginx /etc/nginx/sites-available/
COPY srcs/phpMyAdmin /var/www/gconde/html/phpmyadmin
COPY srcs/index.html /var/www/gconde/html
COPY srcs/config.sql ./
COPY srcs/wordpress.sql ./
RUN rm -rf /etc/nginx/sites-available/default && \
	rm -rf /etc/nginx/sites-enabled/default && \
	ln -fs /etc/nginx/sites-available/config_nginx /etc/nginx/sites-enabled/
RUN  chmod 700 /etc/ssl/private &&\
	 openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=SP/ST=Spain/L=Madrid/O=42/CN=127.0.0.1" -keyout /etc/ssl/private/nginx_server.key -out /etc/ssl/certs/nginx_server.crt && \
openssl dhparam -out /etc/nginx/dhparam.pem 1000 && \
chown -R www-data:www-data /var/www/* && \
chmod -R 755 /var/www/*

RUN service mysql start && \
	mysql -u root --password= < /config.sql && \
	mysql wordpress -u root --password=  < ./wordpress.sql
EXPOSE 80 443

CMD service nginx start && \
	service mysql restart && \
	service php7.3-fpm start && \
	bash
