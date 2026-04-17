FROM quay.io/fedora/fedora-silverblue:latest

RUN mkdir /build
WORKDIR /build

COPY ./scripts /build/scripts

COPY ./install/multimedia.sh ./install/multimedia.sh
RUN ./install/multimedia.sh

COPY ./install/development.sh ./install/development.sh
COPY ./repos/vscode.repo /build/repos/vscode.repo
RUN ./install/development.sh

COPY ./install/containers.sh ./install/containers.sh
COPY ./repos/docker-ce.repo /build/repos/docker-ce.repo
RUN ./install/containers.sh


RUN rm -rf /build
