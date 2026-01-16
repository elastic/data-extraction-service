.PHONY: e2e clean

current_dir = $(shell pwd)

PYTHON = python3.12

bin/python: tests-requirements.txt
	$(PYTHON) -m venv .
	bin/pip install -r tests-requirements.txt
	touch bin/python

clean:
	rm -rf bin lib include pyvenv.cfg

e2e: bin/python
	- docker stop extraction-service
	- docker rm extraction-service
	docker build --platform=linux/arm64 -t extraction-service .
	docker run -v $(current_dir)/tests/samples:/app/files -d -p 8090:8090 -it --name extraction-service extraction-service
	sleep 5
	bin/python3 -m pytest tests/
