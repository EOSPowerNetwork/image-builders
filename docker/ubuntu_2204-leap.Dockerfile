ARG LEAP_VER
FROM ghcr.io/eospowernetwork/leap-dependencies-ubuntu-2204:${LEAP_VER}

ENV LEAP_VERSION=${LEAP_VER}

# Install leap
RUN mkdir -p /root/leap \
    && cd /root/leap \
    && git clone https://github.com/AntelopeIO/leap.git .  \
    && git fetch --all --tags                              \
    && git checkout v$ENV:LEAP_VERSION                     \
    && git submodule update --init --recursive

# Build & install leap
RUN mkdir -p /root/leap/build \
    && cd /root/leap/build \
    && cmake -DCMAKE_BUILD_TYPE=Release        \
             -DDISABLE_WASM_SPEC_TESTS=yes ..  \
    && make -j $(nproc) \
    && make install

# Build and install CLSDK dependencies, not sure if these are needed
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -yq      \
        binaryen                \
        gdb                     \
        libtinfo5               \
        libusb-1.0-0-dev        \
        libzstd-dev             \
        pkg-config              \
        time                    \
        wget                    \
    && apt-get clean -yq \
    && rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.title="Ubuntu 22.04 Leap build" \
    org.opencontainers.image.authors="EOS Power Network" \
    org.opencontainers.image.vendor="EOS Power Network" \
    org.opencontainers.image.version="v${LEAP_VER}" \
    org.opencontainers.image.url="url to image" \
    org.opencontainers.image.documentation="url to docs" \
    org.opencontainers.image.description="Image contains the build dependencies as specified in leap/.cicd/platforms/ubuntu22.Dockerfile, as well as leap, built from source."
