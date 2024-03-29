[![Build status](https://badge.buildkite.com/530780aa3d763ae5f47e75d21d1dfecd240af640b24fc61455.svg)](https://buildkite.com/elastic/data-extraction-service)
# Elastic Data Extraction Service

For extracting data and metadata from binary documents.

The Data Extraction Service was built with [Elastic connectors](https://github.com/elastic/connectors) in mind.
While it can be used by other clients as well, its chief goal is to enable extracting text data from large binary documents "on the edge",
and to provide a simple, stateless, load-balanceable, interface.

If you have a need to extract text from office documents larger than 100mb ([see `http.max_content_length`](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-network.html#http-settings)) 
before ingesting to Elasticsearch, the Data Extraction Service is for you.

For product documentation and version compatibility, see: [Connectors -> Content Extraction](https://www.elastic.co/guide/en/enterprise-search/current/connectors-content-extraction.html#connectors-content-extraction-local).

## How it works

The artifact producted by this repo is the `data-extraction-service` Docker image.
See https://www.docker.elastic.co/r/enterprise-search/data-extraction-service for the full list of artifacts/versions.

This docker image runs [openresty](https://openresty.org/en/getting-started.html) and [tika-server](https://cwiki.apache.org/confluence/display/TIKA/TikaServer) as background services, which is handled by [openrc](https://wiki.gentoo.org/wiki/OpenRC).


### Usage

First, pull your image of choice.
You can find the latest version by looking at https://www.docker.elastic.co/r/enterprise-search/data-extraction-service.

```sh
# replace "<version>" with your selected version
$ docker pull docker.elastic.co/enterprise-search/data-extraction-service:<version>
```

Then, start a container from the image with:
```sh
$ docker run \
  -p 8090:8090 \
  -it \
  --name extraction-service \
  docker.elastic.co/enterprise-search/data-extraction-service:<version>
```

You can validate that the service is running with:
```sh
$ curl -X GET http://localhost:8090/ping/ # this should output "Running!"
```

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

To extract a file locally, it must first be added to the docker container.
You can manually do this using `docker cp` or you can mount a volume to share files with a different system.
You must specify the full filepath in the `local_file_path` argument.
Note: avoid using only `/app` as your chosen filedrop path. If a config file is overwritten in this directory, data-extraction-service may break. If you intend to use `/app`, be sure to append a further directory, e.g. `/app/files`.

With `docker cp`
```sh
$ docker cp /path/to/file.name extraction-service:/app/files/file.name
$ curl -X PUT http://localhost:8090/extract_text/?local_file_path=/app/files/file.name | jq
```

With volume sharing.
```sh
$ docker run \
  -p 8090:8090 \
  -it \
  --name extraction-service \
  -v /local/file/location:/app/files \
  docker.elastic.co/enterprise-search/data-extraction-service:<version>
```

For volume sharing, `/local/file/location:/app/files` can also be replaced with `docker-volume-name:/app/files` if you intend to share files between two docker containers. Check the [docker volume docs](https://docs.docker.com/storage/volumes/) for more details.
Doing this will also require a [shared network](https://docs.docker.com/engine/reference/commandline/network_connect/).

You can read more about using local file pointers in the [product documentation for using file pointers](https://www.elastic.co/guide/en/enterprise-search/current/connectors-content-extraction.html#connectors-content-extraction-data-extraction-service-file-pointers).

### Logging

The running docker image produces log files for each of its underlying components.
You can find them at:

- Openresty logs: `/var/log/openresty.log`
- Tikaserver java logs: `/var/log/tika.log`

### Local Setup

To build the docker image locally, run:
```sh
$ docker build --platform=linux/arm64 -t extraction-service .
```

Run your new image:
```sh
$ docker run -p 8090:8090 -it --name extraction-service extraction-service
```
(Add `-d` to run detached, or `--rm` if you want the docker container to be deleted when you exit the window)

To remove the detached container:
```sh
$ docker stop extraction-service
$ docker rm extraction-service
```


## Releasing (employees only)

To release a new version of Elastic Extraction Service, you need to go to [buildkite release pipeline](https://buildkite.com/elastic/data-extraction-service-release), 
1. Click `New Build`, 
2. Select `HEAD` for `Commit`. 
3. For `Branch`, choose `main` to release a new minor version, or choose the relevant maintenance branch (`x.y`) to release a new patch version.
4. click `Create Build`. 

This will release a new version, create a new maintenance branch (if applicable), build a docker image, and push it to https://docker.elastic.co, and bump the version file(s) to the next version(s).


