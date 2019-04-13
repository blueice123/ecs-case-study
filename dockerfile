#
# Nginx Dockerfile
#
# https://github.com/dockerfile/nginx
#

# Pull base image.
#FROM dockerfile/ubuntu
FROM ubuntu:14.04

# Install Nginx.
RUN \
  apt-get update && \
  apt-get install -y nginx git && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Define mountable directories.
#VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN echo "Blue_Green_Deploy" > /usr/share/nginx/html/health_check

RUN perl -pi -e "s/listen 80 default_server/listen 8080 default_server/g" /etc/nginx/sites-enabled/default
RUN perl -pi -e "s/80 default_server /8080 default_server /g" /etc/nginx/sites-enabled/default

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["nginx"]

# Expose ports.
EXPOSE 8080
