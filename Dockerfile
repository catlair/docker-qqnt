# syntax=docker/dockerfile:1

FROM ifrstr/novnc:0.0.2

ARG BUILD_QQNT_LINK
ARG BUILD_ARCH

COPY --chmod=0755 rootfs /

RUN useradd catlair && \
  chown -R catlair:catlair /var/www && \
  apt update && \
  \
  # Install packages
  apt install -y fonts-noto-cjk wget && \
  \
  # QQNT
  wget -O /tmp/qqnt.deb ${BUILD_QQNT_LINK}_${BUILD_ARCH}.deb && \
  apt install -y /tmp/qqnt.deb && \
  \
  # Cleanup
  apt purge -y wget && \
  apt autoremove -y && \
  apt clean && \
  rm -rf \
  /var/lib/apt/lists/* \
  /tmp/* \
  /var/tmp/*

USER catlair
