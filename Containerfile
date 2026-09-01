ARG FEDORA_MAJOR_VERSION=44

FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION} AS kernel-version

RUN kernel_package=$(rpm -q kernel) && \
    kernel_version=${kernel_package#kernel-} && \
    echo KERNEL_VERSION="$kernel_version" > /tmp/environment

RUN cat /tmp/environment

FROM quay.io/fedora/fedora:${FEDORA_MAJOR_VERSION} AS akmods

ENV BUILD_DIR=/build
ENV SCRIPTS_DIR=${BUILD_DIR}/scripts
ENV PACKAGES_DIR=${BUILD_DIR}/packages
ENV REPOS_DIR=${BUILD_DIR}/repos
ENV KMODS_RPM_DIR=${BUILD_DIR}/akmods-rpms
ENV ENV_FILE=${BUILD_DIR}/environment
ENV PATH=${PATH}:${BUILD_DIR}/scripts

COPY --from=kernel-version /tmp/environment ${ENV_FILE}
RUN source $ENV_FILE && dnf -y --setopt=install_weak_deps=False install \
    "kernel-core-$KERNEL_VERSION" \
    "kernel-devel-$KERNEL_VERSION"

COPY ./scripts $SCRIPTS_DIR
COPY ./repos $REPOS_DIR
COPY ./packages $PACKAGES_DIR

RUN source $ENV_FILE && build-akmods $KERNEL_VERSION $KMODS_RPM_DIR

FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION}

ENV BUILD_DIR=/build
ENV SCRIPTS_DIR=${BUILD_DIR}/scripts
ENV PACKAGES_DIR=${BUILD_DIR}/packages
ENV REPOS_DIR=${BUILD_DIR}/repos
ENV KMODS_RPM_DIR=${BUILD_DIR}/akmods-rpms
ENV PATH=${PATH}:${BUILD_DIR}/scripts

COPY --from=akmods $KMODS_RPM_DIR $KMODS_RPM_DIR
COPY ./scripts $SCRIPTS_DIR
COPY ./repos $REPOS_DIR

RUN --mount=type=cache,dst=/var/cache \
    rm -rf /var/cache/*

COPY ./packages/multimedia.yml ${PACKAGES_DIR}/
RUN --mount=type=cache,dst=/var/cache \
    install-packages multimedia.yml

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

COPY ./packages/utilities.yml ${PACKAGES_DIR}/
RUN --mount=type=cache,dst=/var/cache \
    install-packages utilities.yml

RUN rm -rf $BUILD_DIR
