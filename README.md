# Elastic Extraction Service

For extracting data and metadata from binary documents.
This docker image runs [openresty](https://openresty.org/en/getting-started.html) and [tika-server](https://cwiki.apache.org/confluence/display/TIKA/TikaServer) as background services, which is handled by [openrc](https://wiki.gentoo.org/wiki/OpenRC).

## Local Setup

Build:
```sh
$ docker build --platform=linux/arm64 -t extraction-service .
```

Run:
```sh
$ docker run -p 8090:8090 -it --name extraction-service extraction-service
```
(Add `-d` to run detached, or `--rm` if you want the docker container to be deleted when you exit the window)

To remove the detached container:
```sh
$ docker stop extraction-service
$ docker rm extraction-service
```

## Usage

Call the running service to extract file content:
```sh
$ curl -F upload=@/path/to/file.name http://localhost:8090/extract_text/ -H "Accept: application/json" | jq
```

## Logging

Openresty logs: `/var/log/openresty.log` and `/var/log/openresty_errors.log`
