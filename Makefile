# Makefile

all: help

# Show a message to list all available options
help:
	@echo "Please type 'make' followed by the target name, available targets:"
	@echo "- ubuntu-22-04_x86"

# Build target
ubuntu-22-04_x86:
	docker build --no-cache -t $@ -f ./builders/$@/Dockerfile ./builders/$@/
	docker run --rm -v `pwd`/build:/outside $@ /bin/bash -c "cp /tmp/rippled /outside/"

.PHONY: all help ubuntu-22-04_x86