FROM quay.io/fedora/fedora-silverblue:latest

ENV BUILD_DIR=/build
ENV SCRIPTS_DIR=${BUILD_DIR}/scripts
ENV PACKAGES_DIR=${BUILD_DIR}/packages
ENV REPOS_DIR=${BUILD_DIR}/repos
ENV PATH=${PATH}:${BUILD_DIR}/scripts

COPY ./scripts $SCRIPTS_DIR
COPY ./packages $PACKAGES_DIR
COPY ./repos $REPOS_DIR

WORKDIR $BUILD_DIR

RUN --mount=type=cache,dst=/var/cache \
    rm -rf /var/cache/*

RUN --mount=type=cache,dst=/var/cache \
    install-packages containers.yml

RUN --mount=type=cache,dst=/var/cache \
    install-packages development.yml

RUN --mount=type=cache,dst=/var/cache \
    install-packages gaming.yml

RUN --mount=type=cache,dst=/var/cache \
    install-packages gnome-extensions.yml

RUN --mount=type=cache,dst=/var/cache \
    install-packages multimedia.yml

RUN rm -rf $BUILD_DIR
