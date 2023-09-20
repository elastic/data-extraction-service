FROM openresty/openresty:alpine
EXPOSE 8090

WORKDIR /app

# these fix various known issues, don't remove
VOLUME /sys/fs/cgroup
RUN mkdir /run/openrc\
  && touch /run/openrc/softlevel

# get services we need
RUN apk add --no-cache openrc openjdk8 curl
RUN wget https://archive.apache.org/dist/tika/2.8.0/tika-server-standard-2.8.0.jar

# file setup
COPY runner.sh runner.sh
COPY tika/ .
COPY nginx/ .
COPY openrc/ /etc/init.d/

RUN ln -sf /app/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
RUN chmod +x /etc/init.d/tika
RUN chmod +x /etc/init.d/openresty

HEALTHCHECK CMD curl --fail http://localhost:8090/ping/ || exit 1

# run tika and openresty as services
CMD ["/bin/sh", "-C", "runner.sh"]
