FROM openresty/openresty:alpine

VOLUME /sys/fs/cgroup

COPY tika /etc/init.d/tika
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

RUN chmod +x /etc/init.d/tika
RUN chown root:root /etc/init.d/tika

RUN apk add openrc openjdk8 wget --no-cache

RUN mkdir /run/openrc\
  && touch /run/openrc/softlevel

RUN wget -P /app https://downloads.apache.org/tika/2.8.0/tika-server-standard-2.8.0.jar


RUN rc-update add tika
RUN rc-service tika start

EXPOSE 8090

CMD /usr/local/openresty/bin/openresty -g "daemon off;"