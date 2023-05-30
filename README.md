# Elastic Extraction Service

For extracting data and metadata from binary documents

Run locally with

```sh
$ docker build --platform=linux/arm64 -t extraction-service .
$ docker run -p 8090:8090 -it --name extraction-service extraction-service
```

To remove the container (for example to re-run and test changes)
```sh
$ docker stop extraction-service
$ docker rm extraction-service
```
