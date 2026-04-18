FROM quay.io/fedora/fedora-silverblue:latest

RUN mkdir /build
WORKDIR /build
COPY ./scripts /build/scripts

RUN --mount=type=cache,dst=/var/cache \
    rm -rf /var/cache/*

COPY ./install/multimedia.sh ./install/multimedia.sh
RUN --mount=type=cache,dst=/var/cache \
    ./install/multimedia.sh

COPY ./install/development.sh ./install/development.sh
COPY ./repos/vscode.repo /build/repos/vscode.repo
RUN --mount=type=cache,dst=/var/cache \
    ./install/development.sh

COPY ./install/containers.sh ./install/containers.sh
COPY ./repos/docker-ce.repo /build/repos/docker-ce.repo
RUN --mount=type=cache,dst=/var/cache \
    ./install/containers.sh

COPY ./install/gaming.sh ./install/gaming.sh
COPY ./repos/ilyaz-LACT.repo /build/repos/ilyaz-LACT.repo
COPY ./repos/faugus-faugus-launcher.repo /build/repos/faugus-faugus-launcher.repo
COPY ./repos/pvermeer-sunshine.repo /build/repos/pvermeer-sunshine.repo
COPY ./repos/pvermeer-virtual-display.repo /build/repos/pvermeer-virtual-display.repo
COPY ./repos/pvermeer-gamescope-session-guide.repo /build/repos/pvermeer-gamescope-session-guide.repo
RUN --mount=type=cache,dst=/var/cache \
    ./install/gaming.sh

RUN rm -rf /build
