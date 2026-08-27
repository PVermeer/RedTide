FROM quay.io/fedora/fedora-silverblue:latest

ENV BUILD_DIR=/build
ENV SCRIPTS_DIR=${BUILD_DIR}/scripts
ENV PACKAGES_DIR=${BUILD_DIR}/packages
ENV REPOS_DIR=${BUILD_DIR}/repos
ENV PATH=${PATH}:${BUILD_DIR}/scripts

COPY ./scripts $SCRIPTS_DIR
COPY ./repos $REPOS_DIR

WORKDIR $BUILD_DIR

RUN --mount=type=cache,dst=/var/cache \
    rm -rf /var/cache/*

COPY ./packages/containers.yml ${PACKAGES_DIR}/
RUN --mount=type=cache,dst=/var/cache \
    install-packages containers.yml

COPY ./packages/development.yml ${PACKAGES_DIR}/
RUN --mount=type=cache,dst=/var/cache \
    install-packages development.yml

COPY ./packages/gaming.yml ${PACKAGES_DIR}/
RUN --mount=type=cache,dst=/var/cache \
    install-packages gaming.yml

COPY ./packages/gnome-extensions.yml ${PACKAGES_DIR}/
RUN --mount=type=cache,dst=/var/cache \
    install-packages gnome-extensions.yml

COPY ./packages/multimedia.yml ${PACKAGES_DIR}/
RUN --mount=type=cache,dst=/var/cache \
    install-packages multimedia.yml

RUN rm -rf $BUILD_DIR
