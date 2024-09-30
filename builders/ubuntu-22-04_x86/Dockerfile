FROM ubuntu:22.04

ARG CACHEBUST=5
ARG CMAKE_VERSION=3.25.1

ENV CMAKE_VERSION=${CMAKE_VERSION}

WORKDIR /root
COPY prerequisites.sh .
RUN ./prerequisites.sh
WORKDIR /root
COPY compilation.sh .
RUN ./compilation.sh