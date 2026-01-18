FROM ubuntu:18.04
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=10.24.1
ENV VIPS_VERSION=8.10.6

ENV PATH=/node_modules/.bin:$PATH

# Base tooling + Python2 for node-gyp (Node 10) + build toolchain
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates curl xz-utils \
  python2.7 make g++ pkg-config \
  nasm \
  git \
  && rm -rf /var/lib/apt/lists/*

# Ensure node-gyp uses python2
RUN ln -sf /usr/bin/python2.7 /usr/local/bin/python \
 && ln -sf /usr/bin/python2.7 /usr/bin/python2

# Build libvips >= 8.10.5 from source (bionic repo is too old for sharp@0.27.2)
RUN apt-get update && apt-get install -y --no-install-recommends \
  autoconf automake libtool gettext \
  glib2.0-dev \
  libexpat1-dev \
  libjpeg-turbo8-dev libpng-dev libwebp-dev libtiff5-dev libgif-dev \
  libexif-dev libxml2-dev zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*


RUN case "${TARGETARCH}" in \
        "arm64") arch="arm64" ;; \
        "amd64") arch="x64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac \
 && curl -fsSL https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz -o /tmp/vips.tar.gz \
 && tar -xzf /tmp/vips.tar.gz -C /tmp \
 && cd /tmp/vips-${VIPS_VERSION} \
 && ./configure --disable-debug --without-python \
 && make -j"$(nproc)" \
 && make install \
 && ldconfig \
 && rm -rf /tmp/vips* /tmp/vips.tar.gz

# Some builds expect <glib-object.h> at /usr/include
RUN test -f /usr/include/glib-object.h || ln -s /usr/include/glib-2.0/gobject/glib-object.h /usr/include/glib-object.h

RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${TARGETARCH}.tar.xz -o /tmp/node.tar.xz \
 && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
 && rm /tmp/node.tar.xz \
 && node -v && npm -v

COPY package*.json /
ENV npm_config_python=/usr/bin/python2.7
RUN cd / && npm install

WORKDIR /app

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
