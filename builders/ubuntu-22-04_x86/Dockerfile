FROM ubuntu:22.04

ARG CACHEBUST=5
ARG CMAKE_VERSION=3.25.1

ENV CMAKE_VERSION=${CMAKE_VERSION}

RUN mkdir /build
RUN  cp /bin/bash /build/

# # Install prerequisites
WORKDIR /root
COPY prerequisites.sh .
RUN ./prerequisites.sh

# # Make rippled build
WORKDIR /root
COPY compilation.sh .
RUN ./compilation.sh

# # Copy rippled binary
RUN cp /build/rippled-2.2.3/.build/rippled /tmp/rippled