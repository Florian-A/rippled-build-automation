# Makefile

all: help

# Show a message to list all available options
help:
	@echo "Please choose a target to build:"
	@echo "  - ubuntu-22-04_x86"


ubuntu-22-04_x86:
	docker build -t ubuntu-22-04_x86 -f ubuntu-22-04_x86 .

.PHONY: all help ubuntu-22-04_x86