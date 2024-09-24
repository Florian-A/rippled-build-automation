# Makefile

all: help

# Show a message to list all available options
help:
	@echo "Please choose a target to build:"
	@echo "  - ubuntu-22-04_x86"

# Build target
ubuntu-22-04_x86:
	docker build -t ubuntu-22-04_x86 -f ./builders/ubuntu-22-04_x86/Dockerfile .

.PHONY: all help ubuntu-22-04_x86