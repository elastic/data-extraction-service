.PHONY: test


current_dir = $(shell pwd)

bin/python:
	python3 -m venv .
	bin/pip install -r tests-requirements.txt


e2e: bin/python
	- docker stop extraction-service
	- docker rm extraction-service
	docker build --platform=linux/arm64 -t extraction-service .
	docker run -v $(current_dir)/tests/samples:/app/files -d -p 8090:8090 -it --name extraction-service extraction-service
	sleep 5
	bin/python3 -m pytest tests/
