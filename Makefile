# Makefile

all: ubuntu-22-04_x86

# Show a message to list all available options
help:
	@echo "Please choose a target to build:"
	@echo "  - ubuntu-22-04_x86"

# Build target
ubuntu-22-04_x86:
	docker build --no-cache -t ubuntu-22-04_x86 -f ./builders/ubuntu-22-04_x86/Dockerfile ./builders/ubuntu-22-04_x86/
	docker run --rm -v $(pwd)/build:/build ubuntu-22-04_x86
	docker run -it -v $(pwd)/build:/build ubuntu-22-04_x86 /bin/cp /tmp/rippled /build/rippled

.PHONY: all help ubuntu-22-04_x86