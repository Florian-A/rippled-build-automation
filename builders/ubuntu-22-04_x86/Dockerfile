FROM ubuntu:22.04
ARG CACHEBUST=5
WORKDIR /root
COPY prerequisites.sh .
RUN ./prerequisites.sh && rm prerequisites.sh
COPY compilation.sh .
RUN ./compilation.sh && rm compilation.sh