# Elastic Extraction Service

For extracting data and metadata from binary documents.
This docker image runs [openresty](https://openresty.org/en/getting-started.html) and [tika-server](https://cwiki.apache.org/confluence/display/TIKA/TikaServer) as background services, which is handled by [openrc](https://wiki.gentoo.org/wiki/OpenRC).

## Local Setup

Run locally with

```sh
$ docker build --platform=linux/arm64 -t extraction-service .
$ docker run -p 8090:8090 -it --rm --name extraction-service extraction-service
```

To remove the container (for example to re-run and test changes)
```sh
$ docker stop extraction-service
$ docker rm extraction-service
```

## Logging

Openresty logs: `/var/log/openresty.log`
