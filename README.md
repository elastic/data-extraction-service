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

To send a file to be extracted:
```zsh
$ curl -X PUT http://localhost:8090/extract_text/ \
  -T /path/to/file.name
```

This will return a response like the following:
```json
{
  "extracted_text": "Hello world!",
  "_meta": {
    "X-ELASTIC:service": "tika",
    "X-ELASTIC:TIKA:parsed_by": ["parser1", "parser2"]
  }
}
```

To extract a file locally, it must first be added to the docker container. You can manually do this using `docker cp` or you can mount a volume to share files with a different system.
You must specify the full filepath in the `local_file_path` argument.
Note: avoid using only `/app` as your chosen filedrop path. If a config file is overwritten in this directory, data-extraction-service may break. If you intend to use `/app`, be sure to append a further directory, e.g. `/app/files`.

With `docker cp`
```sh
$ docker run -p 8090:8090 -it --name extraction-service extraction-service
$ docker cp /path/to/file.name extraction-service:/app/files/file.name
$ curl -X PUT http://localhost:8090/extract_text/?local_file_path=/app/files/file.name | jq
```

With volume sharing.
```sh
$ docker run -p 8090:8090 -it --name extraction-service -v /local/file/location:/app/files extraction-service
```

For volume sharing, `/local/file/location:/app/files` can also be replaced with `docker-volume-name:/app/files` if you intend to share files between two docker containers. Check the [docker volume docs](https://docs.docker.com/storage/volumes/) for more details. Doing this will also require a [shared network](https://docs.docker.com/engine/reference/commandline/network_connect/).

## Release

To release a new version of Elastic Extraction Service, you need to go to [buildkite release pipeline](https://buildkite.com/elastic/data-extraction-service-release), click `New Build`, select `HEAD` for `Commit` and `main` for `Branch` and click `Create Build`. This will release a new version, build a docker image and push it to https://docker.elastic.co, and bump the version to the next minor.

## Logging

- Openresty logs: `/var/log/openresty.log`
- Tikaserver java logs: `/var/log/tika.log`
