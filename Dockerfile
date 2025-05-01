ARG VERSION_ARG="latest"
FROM scratch AS build-amd64

COPY --from=qemux/qemu:7.11 / /

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

RUN set -eu && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        wsdd \
        samba \
        wimtools \
        dos2unix \
        cabextract \
        libxml2-utils \
        libarchive-tools \
        netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=755 ./src /run/
COPY --chmod=755 ./assets /run/assets

ADD --chmod=664 https://github.com/qemus/virtiso-whql/releases/download/v1.9.45-0/virtio-win-1.9.45.tar.xz /var/drivers.txz

FROM dockurr/windows-arm:${VERSION_ARG} AS build-arm64
FROM build-${TARGETARCH}

ARG VERSION_ARG="0.00"
RUN echo "$VERSION_ARG" > /run/version

VOLUME /storage
EXPOSE 3389 8006

ENV VERSION="https://archive.org/download/windows-server-2025-beta-build-25295-lite-os-tiny-server-11/Windows%20Server%202025%20Beta%20Build%2025295%20-%20LiteOS%20%23TinyServer11.iso"
ENV RAM_SIZE="4G"
ENV CPU_CORES="2"
ENV DISK_SIZE="64G"
ENV KVM="N"

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
