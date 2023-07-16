ARG LEAP_VER
FROM ghcr.io/eospowernetwork/leap-dependencies-ubuntu-2204:${LEAP_VER}

# Install leap
ARG LEAP_VERSION=v${LEAP_VER}
WORKDIR /root/leap
RUN git clone https://github.com/AntelopeIO/leap.git .  \
    && git fetch --all --tags                           \
    && git checkout ${LEAP_VERSION}                     \
    && git submodule update --init --recursive

# Build & install leap
WORKDIR /root/leap/build
RUN cmake -DCMAKE_BUILD_TYPE=Release        \
          -DDISABLE_WASM_SPEC_TESTS=yes ..  \
    && make -j $(nproc) \
    && make install

LABEL org.opencontainers.image.title="Ubuntu 22.04 Leap build" \
    org.opencontainers.image.authors="EOS Power Network" \
    org.opencontainers.image.vendor="EOS Power Network" \
    org.opencontainers.image.version="v${LEAP_VER}" \
    org.opencontainers.image.url="url to image" \
    org.opencontainers.image.documentation="url to docs" \
    org.opencontainers.image.description="Image contains the build dependencies as specified in leap/.cicd/platforms/ubuntu22.Dockerfile, as well as leap, built from source."
