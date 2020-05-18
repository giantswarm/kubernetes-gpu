.PHONY: help build push

help:
	@echo ''
	@echo 'Usage: make [TARGET] [EXTRA_ARGUMENTS]'
	@echo 'Targets:'
	@echo '  build    	build docker --image-- '
	@echo '  push  	push docker --image-- '
	@echo ''
	@echo 'Extra arguments:'
	@echo 'driver-version=:	make driver-version="390.116"'

build:
	docker build --build-arg driver-version=$(driver-version) -t quay.io/giantswarm/coreos-nvidia-driver-installer:$(driver-version) .

push:
	docker push quay.io/giantswarm/coreos-nvidia-driver-installer:$(driver-version)
