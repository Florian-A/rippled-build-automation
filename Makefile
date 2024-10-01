# Makefile

all: ubuntu-22-04_x86

# Show a message to list all available options
help:
	@echo "Please choose a target to build:"
	@echo "  - ubuntu-22-04_x86"

# Build target
ubuntu-22-04_x86:
	docker build --no-cache -t $@ -f ./builders/$@/Dockerfile ./builders/$@/
	docker run --rm -v $(pwd)/build:/build
	docker run -it -v $(pwd)/build:/build $@ /bin/cp /tmp/rippled build

.PHONY: all help ubuntu-22-04_x86