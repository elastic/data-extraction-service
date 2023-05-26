# Elastic Extraction Service

For extracting data and metadata from binary documents

Run locally with

```sh
$ docker build --platform=linux/arm64 -t extraction-service .
$ docker run -p 8090:8090 -i -t extraction-service
```