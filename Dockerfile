FROM debian

RUN apt-get -y update && apt-get -y install nginx

COPY default /etc/nginx/sites-available/default

RUN echo "Dockerfile Test Nginx on debian-test image || Test ganti kode" > /usr/share/nginx/html/index.html

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]