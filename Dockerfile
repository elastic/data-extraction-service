FROM openresty/openresty:alpine
EXPOSE 8090

# these fix various known issues, don't remove
VOLUME /sys/fs/cgroup
RUN mkdir /run/openrc\
  && touch /run/openrc/softlevel

# file setup
copy runner.sh runner.sh
COPY tika /etc/init.d/tika
COPY openresty /etc/init.d/openresty
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

RUN chmod +x /etc/init.d/tika
RUN chmod +x /etc/init.d/openresty
RUN chmod +x /runner.sh
RUN chown root:root /etc/init.d/tika
RUN chown root:root /etc/init.d/openresty
RUN chown root:root /runner.sh

# get services we need
RUN apk add lsof openrc openjdk8 wget
RUN wget -P /app https://downloads.apache.org/tika/2.8.0/tika-server-standard-2.8.0.jar

# run tika and openresty as services
CMD ["bin/sh", "-C", "./runner.sh"]