.PHONY: e2e fips-e2e clean install-python

current_dir = $(shell pwd)

PYTHON = python3.12

install-python:
	@if ! command -v $(PYTHON) >/dev/null 2>&1; then \
		echo "$(PYTHON) not found, installing..."; \
		if command -v yum >/dev/null 2>&1; then \
			sudo yum install -y $(PYTHON) $(PYTHON)-pip; \
		elif command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get update && apt-get install -y $(PYTHON) $(PYTHON)-venv; \
		fi; \
	fi

bin/python: tests-requirements.txt
	$(PYTHON) -m venv .
	bin/pip install -r tests-requirements.txt
	touch bin/python

clean:
	rm -rf bin lib include pyvenv.cfg

e2e: bin/python
	@if ! docker image inspect extraction-service >/dev/null 2>&1; then \
		echo "extraction-service image not found, building..."; \
		$(MAKE) build; \
	fi
	@echo "=== Running e2e tests ==="
	docker run -v $(current_dir)/tests/samples:/app/files -d -p 8090:8090 --name extraction-service extraction-service
	sleep 5
	bin/python3 -m pytest tests/ -v; ret=$$?; docker stop extraction-service; docker rm extraction-service; exit $$ret

fips-e2e: bin/python
	@if ! docker image inspect extraction-service-fips >/dev/null 2>&1; then \
		echo "extraction-service-fips image not found, building..."; \
		$(MAKE) fips-build; \
	fi
	@echo "=== Running e2e tests in FIPS mode ==="
	docker run -v $(current_dir)/tests/samples:/app/files -d -p 8090:8090 --name extraction-service extraction-service-fips
	sleep 10
	FIPS_MODE=true bin/python3 -m pytest tests/ -v; ret=$$?; docker stop extraction-service; docker rm extraction-service; exit $$ret

fips-build:
	docker build -f Dockerfile.fips -t extraction-service-fips .

build:
	docker build -t extraction-service .
