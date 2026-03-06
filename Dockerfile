FROM openresty/openresty:1.29.2.1-0-alpine@sha256:711a9c269a6e4f4b5540fe6bdb4924bba14fc95ff16a77d6da76f89a78ad3e11
EXPOSE 8090

WORKDIR /app

# these fix various known issues, don't remove
VOLUME /sys/fs/cgroup
RUN mkdir /run/openrc\
  && touch /run/openrc/softlevel

# get services we need
RUN apk add --no-cache openrc openjdk17-jre-headless curl
RUN wget https://archive.apache.org/dist/tika/3.2.3/tika-server-standard-3.2.3.jar

# file setup
COPY runner.sh runner.sh
COPY tika/ .
COPY nginx/ .
COPY openrc/ /etc/init.d/
COPY NOTICE.txt .
COPY LICENSE .

RUN ln -sf /app/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
RUN chmod +x /etc/init.d/tika
RUN chmod +x /etc/init.d/openresty

HEALTHCHECK CMD curl --fail http://localhost:8090/ping/ || exit 1

# run tika and openresty as services
CMD ["/bin/sh", "-C", "runner.sh"]
