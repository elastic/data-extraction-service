FROM openresty/openresty:alpine
EXPOSE 8090

WORKDIR /app

# these fix various known issues, don't remove
VOLUME /sys/fs/cgroup
RUN mkdir /run/openrc\
  && touch /run/openrc/softlevel

# get services we need
RUN apk add openrc openjdk8
RUN wget https://downloads.apache.org/tika/2.8.0/tika-server-standard-2.8.0.jar

# file setup
copy runner.sh runner.sh
COPY tika/tika /etc/init.d/tika
COPY tika/log4j2.xml log4j2.xml
COPY nginx/openresty /etc/init.d/openresty
COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

RUN chmod +x /etc/init.d/tika
RUN chmod +x /etc/init.d/openresty
RUN chmod +x /app/runner.sh
RUN chown root:root /etc/init.d/tika
RUN chown root:root /etc/init.d/openresty
RUN chown root:root /app/runner.sh

# run tika and openresty as services
CMD ["/bin/sh", "-C", "./runner.sh"]