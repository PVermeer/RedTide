FROM quay.io/fedora/fedora-silverblue:latest

RUN mkdir /build
WORKDIR /build

COPY ./scripts /build/scripts

COPY ./install/multimedia.sh ./install/multimedia.sh
RUN ./install/multimedia.sh

RUN rm -rf /build
