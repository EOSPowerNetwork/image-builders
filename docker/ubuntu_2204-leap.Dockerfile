ARG LEAP_VER
FROM ghcr.io/eospowernetwork/leap-dependencies-ubuntu-2204:${LEAP_VER}

# need to redeclare arg to add it to the same build context
ARG LEAP_VER

# Download leap
RUN mkdir -p /root/leap \
    && cd /root/leap \
    && git clone https://github.com/AntelopeIO/leap.git .  \
    && git fetch --all --tags                              \
    && git checkout v${LEAP_VER}                           \
    && git submodule update --init --recursive

# Build & install
RUN mkdir -p /root/leap/build \
    && cd /root/leap/build \
    && cmake -DCMAKE_BUILD_TYPE=Release        \
             -DDISABLE_WASM_SPEC_TESTS=yes ..  \
    && make -j $(nproc) \
    && make install

# Now I need ccache, wasi, and clsdk. CLSDK can currently be taken from the package on gofractally/,
#   but I think ultimately I should fork and host a separate clsdk package from eos power network.

# Build and install CLSDK dependencies
# RUN export DEBIAN_FRONTEND=noninteractive \
#     && apt-get update \
#     && apt-get install -yq      \
#         binaryen                \
#         gdb                     \
#         libtinfo5               \
#         libusb-1.0-0-dev        \
#         libzstd-dev             \
#         pkg-config              \
#         time                    \
#         wget                    \
#     && apt-get clean -yq \
#     && rm -rf /var/lib/apt/lists/*

# RUN cd /root \
#     && curl -LO https://github.com/ccache/ccache/releases/download/v4.3/ccache-4.3.tar.gz \
#     && tar xf ccache-4.3.tar.gz \
#     && cd /root/ccache-4.3 \
#     && cmake . \
#     && make -j \
#     && make -j install \
#     && cd /root \
#     && rm -rf ccache*

# RUN cd /opt \
#     && curl -LO https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-12/wasi-sdk-12.0-linux.tar.gz \
#     && tar xf wasi-sdk-12.0-linux.tar.gz \
#     && rm *.tar.*

# ENV WASI_SDK_PREFIX=/opt/wasi-sdk-12.0

# Removed node install, because i don't think it's needed for clsdk build
# && curl -LO https://nodejs.org/dist/v14.16.0/node-v14.16.0-linux-x64.tar.xz \
# && tar xf node-v14.16.0-linux-x64.tar.xz \
# && export PATH="/opt/node-v14.16.0-linux-x64/bin:$PATH" \
# && npm i -g yarn

LABEL org.opencontainers.image.title="Ubuntu 22.04 Leap build" \
    org.opencontainers.image.authors="EOS Power Network" \
    org.opencontainers.image.vendor="EOS Power Network" \
    org.opencontainers.image.version="v${LEAP_VER}" \
    org.opencontainers.image.url="url to image" \
    org.opencontainers.image.documentation="url to docs" \
    org.opencontainers.image.description="Image contains the build dependencies as specified in leap/.cicd/platforms/ubuntu22.Dockerfile, as well as leap, built from source."
