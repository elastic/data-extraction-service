.PHONY: test

PYTHON=python3.10
current_dir = $(shell pwd)

install:
	$(PYTHON) -m venv .
	bin/pip install --upgrade pip
	bin/pip install -r tests-requirements.txt

e2e: install
	- docker stop extraction-service
	- docker rm extraction-service
	docker build --platform=linux/arm64 -t extraction-service .
	docker run -v $(current_dir)/tests/samples:/app/files -d -p 8090:8090 -it --name extraction-service extraction-service
	sleep 5
	bin/pytest tests/
