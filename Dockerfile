##############################################################################
# Author: MIRKO THULKE
# Copyright (c) 2025, MIRKO THULKE
# All rights reserved.
#
# Dockerfile for Flutter + Rust + Android + Web integration testing
# Fully self-contained environment for desktop, web, and mobile builds.
#
# License: "All Rights Reserved – View Only"

# Permission is hereby granted to view and share this code in its original,
# unmodified form for educational or reference purposes only.

# Any other use, including but not limited to copying, modification,
# redistribution, commercial use, or inclusion in other projects, is strictly
# prohibited without the express written permission of the author.

# The Software is provided "AS IS", without warranty of any kind, express or
# implied, including but not limited to the warranties of merchantability,
# fitness for a particular purpose, and noninfringement. In no event shall the
# author be liable for any claim, damages, or other liability arising from the
# use of the Software.

# Contact: MIRKO THULKE (for permission requests)
##############################################################################

# Notes:
# - Flutter Android builds require Android SDK & NDK.
# - iOS builds cannot be compiled on Linux; Xcode on macOS is required.
# - Rust FFI for Android requires proper NDK toolchains (CC_aarch64_linux_android etc.).


# ------------------------------------------------------------
# How to Use This Dockerfile
# ------------------------------------------------------------

# Build the environment image once:
#   docker build -t flutter_rust_env .
# or as delta build : docker build . -t sudoku:latest

# start an existing container interactively:
#   docker start -ai flutter_rust_env
# stop an existing container interactively:
#  docker stop flutter_rust_env
#  docker kill flutter_rust_env
#  docker rm flutter_rust_env
# 
# Clean build cache only :              docker builder prune
# To force:                             docker builder prune -f
# remove all builds for all builders:   docker builder prune --all -f
#
# Factory reset !! (removes all images, containers, volumes, networks not in use):
#  docker system prune -a --volumes -f
#  docker buildx prune --all --force
#
# enter the docker container interactively:
#   docker run -it --rm -v /home/mirko/sudoku:/app flutter_rust_env /bin/bash
# Run the container with your local project mounted and build the project:
#   docker run --rm -v ${PWD}:/app -w /app flutter_rust_env bash -c "./scripts/build_all.sh release"
# ------------------------------------------------------------


# ------------------------------------------------------------
# Install essential packages
# ------------------------------------------------------------
# - curl, git: download and version control
# - unzip, xz-utils, zip: handle compressed files
# - libglu1-mesa: OpenGL library for desktop GUI tests
# - build-essential, cmake, ninja-build: compilation tools
# - python3, python3-pip, clang, pkg-config: build dependencies
# - openjdk-17-jdk: Android Java SDK



# ------------------------------------------------------------
# Add to Dockerfile after installing essential packages // for debugging on phone
#       Connect Your Android Phone (Windows Host)
#       Enable USB debugging on your phone.
#       Connect the phone via USB.

#       On your Windows host, switch to TCP/IP:
#       adb tcpip 5555
#       adb connect <PHONE_IP>:5555

#       
#       Example:
#       adb connect 192.168.1.42:5555


#       Verify connection:
#       adb devices

#       You should see:
#       192.168.1.42:5555 device

#       Your phone is now reachable over Wi-Fi — Docker doesn’t need USB access.

# ------------------------------------------------------------
# Optional: Setup ADB for Android device debugging over USB/Wi-Fi
# ------------------------------------------------------------

# Steps for connecting an Android phone from host:
# 1. Enable USB debugging on phone.
# 2. adb tcpip 5555 (on host)
# 3. adb connect <PHONE_IP>
# 4. adb devices to verify connection

# ---------- Multi-stage Dockerfile: Flutter + Android + Rust + Chrome ----------
# Build with BuildKit enabled for cache mounts:
#   DOCKER_BUILDKIT=1 docker build -t flutter_rust_env .
# ---------- Multi-stage Dockerfile: Flutter + Android + Rust + Chrome ----------
# Build with BuildKit enabled for cache mounts:
#   DOCKER_BUILDKIT=1 docker build -t flutter_rust_env .


# ============================================================
# Global Build Arguments
# ============================================================

ARG JAVA_VERSION=17
ARG ANDROID_SDK_TOOLS_VERSION=9477386
ARG ANDROID_SDK_ROOT=/opt/android/sdk
ARG FLUTTER_VERSION=3.35.7
ARG RUST_VERSION=1.91.1

ARG NDK_MAIN=28.2.13676358
ARG CMAKE_MAIN=3.22.1
ARG COMPILE_SDK=36
ARG BUILD_TOOLS=36.0.0

ARG BUILD_MODE=ci

# ============================================================
# Stage: base
# ============================================================

FROM ubuntu:22.04 AS base

ARG JAVA_VERSION
ARG ANDROID_SDK_ROOT

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}

# Essential + 32-bit libraries
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      curl wget unzip git xz-utils zip ca-certificates \
      build-essential pkg-config libglu1-mesa clang ninja-build \
      gnupg2 fonts-liberation \
      libc6:i386 libncurses6:i386 libstdc++6:i386 zlib1g:i386 \
      lib32z1 lib32ncurses6 lib32stdc++6 \
 && rm -rf /var/lib/apt/lists/*

# Java
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openjdk-${JAVA_VERSION}-jdk \
 && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN mkdir -p ${ANDROID_SDK_ROOT}

# ============================================================
# Stage: android
# ============================================================

FROM base AS android

ARG ANDROID_SDK_TOOLS_VERSION
ARG ANDROID_SDK_ROOT
ARG COMPILE_SDK
ARG BUILD_TOOLS
ARG NDK_MAIN
ARG CMAKE_MAIN

ENV ANDROID_HOME=${ANDROID_SDK_ROOT}
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${PATH}"

# Retry helper
RUN printf '#!/bin/bash\nset -e\nfor i in 1 2 3; do "$@" && exit 0 || sleep $((i*10)); done; exit 1\n' \
 > /usr/local/bin/retry \
 && chmod +x /usr/local/bin/retry

# Install Android command-line tools (correct layout)
RUN set -eux; \
 cd /tmp; \
 wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O tools.zip; \
 unzip -q tools.zip; \
 mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest; \
 cp -r cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/; \
 chmod -R +x ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin; \
 rm -rf /tmp/*


ENV SDKMANAGER=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager

# Accept licenses (cached)
RUN --mount=type=cache,target=${ANDROID_SDK_ROOT} \
 yes | retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} --sdk_root=${ANDROID_SDK_ROOT} --licenses || true

# Safe packages grouped
RUN --mount=type=cache,target=${ANDROID_SDK_ROOT} \
 retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} \
   "platform-tools" \
   "platforms;android-${COMPILE_SDK}"

# Risky packages isolated
RUN --mount=type=cache,target=${ANDROID_SDK_ROOT} \
 retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} "build-tools;${BUILD_TOOLS}"

RUN --mount=type=cache,target=${ANDROID_SDK_ROOT} \
 retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} "ndk;${NDK_MAIN}"

RUN --mount=type=cache,target=${ANDROID_SDK_ROOT} \
 retry ${SDKMANAGER} --sdk_root=${ANDROID_SDK_ROOT} "cmake;${CMAKE_MAIN}"

# ============================================================
# Stage: flutter
# ============================================================

FROM android AS flutter

ARG FLUTTER_VERSION

ENV FLUTTER_ROOT=/opt/flutter
ENV PATH="${FLUTTER_ROOT}/bin:${FLUTTER_ROOT}/bin/cache/dart-sdk/bin:${PATH}"

RUN git clone --depth 1 https://github.com/flutter/flutter.git ${FLUTTER_ROOT} \
 && cd ${FLUTTER_ROOT} \
 && git fetch --tags \
 && git checkout ${FLUTTER_VERSION}

RUN --mount=type=cache,target=/root/.pub-cache \
 flutter config --no-analytics \
 && flutter precache --android --web

# ============================================================
# Stage: rust
# ============================================================

FROM base AS rust

ARG RUST_VERSION
ENV PATH="/root/.cargo/bin:${PATH}"

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain ${RUST_VERSION} \
 && /root/.cargo/bin/rustup target add \
      aarch64-linux-android \
      armv7-linux-androideabi \
      x86_64-linux-android \
      i686-linux-android

# ============================================================
# Stage: chrome
# ============================================================

FROM base AS chrome

RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
 | gpg --dearmor -o /usr/share/keyrings/google.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
 > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

ENV CHROME_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --headless"

# ============================================================
# Stage: final
# ============================================================

FROM ubuntu:22.04 AS final

ARG JAVA_VERSION
ARG ANDROID_SDK_ROOT

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}
ENV ANDROID_HOME=${ANDROID_SDK_ROOT}
ENV FLUTTER_ROOT=/opt/flutter
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:/root/.cargo/bin:${PATH}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl unzip git xz-utils zip ca-certificates \
      openjdk-${JAVA_VERSION}-jre-headless libglu1-mesa \
 && rm -rf /var/lib/apt/lists/*

COPY --from=flutter /opt/flutter /opt/flutter
COPY --from=android ${ANDROID_SDK_ROOT} ${ANDROID_SDK_ROOT}
COPY --from=chrome /usr/bin/google-chrome /usr/bin/google-chrome
COPY --from=chrome /opt/google /opt/google
COPY --from=rust /root/.cargo /root/.cargo
COPY --from=rust /root/.rustup /root/.rustup

RUN chmod -R a+rX /opt/flutter ${ANDROID_SDK_ROOT} /root/.cargo

RUN flutter config --android-sdk ${ANDROID_SDK_ROOT} --no-analytics \
 && yes | flutter doctor --android-licenses \
 && flutter doctor

WORKDIR /app
CMD ["/bin/bash"]
